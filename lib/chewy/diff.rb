require "chewy/diff/version"
require 'parser'
require 'parser/current'
require '../../fast/lib/fast'
require 'pry'

module Chewy
  module Diff
    def self.changes(before, after)
      return [] if before == after
      ast_before = ast(before)
      ast_after = ast(after)
      return [] if ast_before == ast_after

      from = IndexAnalyzer.new(ast_before)
      to = IndexAnalyzer.new(ast_after)

      diff(from, to)
    end

    def self.diff(from, to)
      removed = from.fields - to.fields
      added =  to.fields - from.fields
#puts "from",from.fields,"to", to.fields
#puts "added", added.inspect, "removed", removed.inspect
      {}.tap do |diff|
        diff[:-] = "#{from.index_name}#{describe(removed)}" if removed.any?
        diff[:+] = "#{from.index_name}#{describe(added)}" if added.any?
      end
    end

    def self.describe fields
      fields.map(&method(:field_name)).flatten
    end

    def self.field_name(field)
      if field.children.size > 2
        field.children[2].children[0]
      else
        field.children[1]
      end
    end

    class IndexAnalyzer
      def initialize ast
        @index_name, @fields =
          Fast.search '(block (send nil define_type $...) ... $...)', ast
      end

      def fields
         @fields.children.select do |field|
           %i[field field_with_crutch witchcraft!].include?(field.children[1])
         end
      end

      def witchcrafts
require 'pry'; binding.pry
        Fast.search('(send nil witchcraft!)', @fields).flatten
      end

      def index_name
        @index_name.children.last
      end
    end

    def self.ast(code)
      Parser::CurrentRuby.parse(code)
    end

  end
end
