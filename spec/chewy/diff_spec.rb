require "spec_helper"

RSpec.describe Chewy::Diff do
  let(:index_before) { <<~RUBY }
    class CitiesIndex < Chewy::Index
      define_type City do
        field :name, value: -> { name.strip }
        field :popularity
      end
    end
  RUBY

  context ".changes" do

    subject { Chewy::Diff.changes(index_before, index_after) }

    context 'equal files should return no difference' do
      let(:index_after) { index_before }

      it { is_expected.to be_empty }
    end

    context 'changed order but not the implementation' do
      let(:index_after) { <<~RUBY }
        class CitiesIndex < Chewy::Index
          define_type City do
            field :popularity
            field :name, value: -> { name.strip }
          end
        end
      RUBY

      it { is_expected.to be_empty }
    end

    context 'ignore preload changes' do
      let(:index_after) { <<~RUBY }
        class CitiesIndex < Chewy::Index
          define_type City.preload(:state) do
            field :name, value: -> { name.strip }
            field :popularity
          end
        end
      RUBY

      it { is_expected.to be_empty }
    end

    context 'add witchcraft!' do
      let(:index_after) { <<~RUBY }
        class CitiesIndex < Chewy::Index
          define_type City do
            field :name, value: -> { name.strip }
            field :popularity
            witchcraft!
          end
        end
      RUBY

      it { is_expected.to eq([ :+, "City[:witchcraft!]" ])}
    end

    context 'changed field implementation' do
      let(:index_after) { <<~RUBY }
        class CitiesIndex < Chewy::Index
          define_type City do
            field :popularity
            field :name, value: -> { name.uppercase }
          end
        end
      RUBY

      specify do
        is_expected.to eq(
          [:-, "City[:name]",
           :+, "City[:name]"]
        )
      end
    end

    context 'added new field implementation' do
      let(:index_after) { <<~RUBY }
        class CitiesIndex < Chewy::Index
          define_type City do
            field :name, value: -> { name.strip }
            field :latitude
            field :longitude
          end
        end
      RUBY

      specify do
        is_expected.to eq([
           :-, "City[:popularity]",
           :+, "City[:latitude, :longitude]"
        ])
      end
    end

    context 'support crutches' do
      let(:index_after) { <<~RUBY }
        class CitiesIndex < Chewy::Index
          define_type City do
            field :name, value: -> { name.strip }
            field_with_crutch :location, :talents, type: 'geo_point'
          end
        end
      RUBY

      specify do
        is_expected.to eq([
          :-, "City[:popularity]",
          :+, "City[:location]"
        ])
      end
    end

    context 'support type changes' do
      let(:index_after) { <<~RUBY }
        class CitiesIndex < Chewy::Index
          define_type City do
            field :name, value: -> { name.strip }
            field :popularity
          end

          define_type State do
            field :name
          end
        end
      RUBY

      specify do
        is_expected.to eq([ :+, "State" ])
      end
    end

    context 'support type changes' do
      let(:index_after) { <<~RUBY }
        class CitiesIndex < Chewy::Index
          define_type Location do
            field :name, value: -> { name.strip }
            field :popularity
          end
        end
      RUBY

      specify do
        is_expected.to eq([ :+, "Location", :-, "City" ])
      end
    end

    context 'file added' do
      let(:index_before) { '' }
      let(:index_after) { <<~RUBY }
        class LocationIndex < Chewy::Index
          define_type Location do
            field :latitude
            field :longitude
          end
        end
      RUBY

      specify do
        is_expected.to eq([:+ , "Location"])
      end
    end

    context 'file removed' do
      let(:index_after) { '' }
      it { is_expected.to eq([:-, "City"]) }
    end
  end
end
