# Chewy::Diff

Chewy diff allows you to verify changes in indices:

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chewy-diff'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chewy-diff

## Usage

Use two files as stream and check the difference in the input:

```ruby

index_before = <<~RUBY
  class CitiesIndex < Chewy::Index
    define_type City do
      field :name, value: -> { name.strip }
      field :popularity
    end
  end
RUBY

index_after_change = <<~RUBY
  class CitiesIndex < Chewy::Index
    define_type City do
      field :name, value: -> { name.upcase }
      field :popularity
    end
  end
RUBY

Chewy::Diff.changes(index_before, index_after) # => [:-, "City[:name]", :+, "City[:name]"]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/chewy-diff. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

