require "chewy/diff/version"
require 'parser'
require 'parser/current'
require 'fast'

module Chewy
  module Diff
    def self.changes(before, after)
      return [] if before == after

      ast_before = ast(before)
      ast_after = ast(after)

      return [] if ast_before == ast_after

      froms, tos = initialize_analysers(ast_before, ast_after)
      output = []
      froms.each_with_index do |from, i|
        to = tos.find{|t|t.index_name == from.index_name}
        if to
          if result = diff(from, to)
            output << result
          end
        end
      end

      index_changes = wrap_index_changes(froms, tos)

      output += index_changes.flatten if index_changes.any?

      output.flatten
    end

    def self.wrap_index_changes(froms, tos)
      indices_from = froms.map{|e|e.index_name.to_s}
      indices_to = tos.map{|e|e.index_name.to_s}
      indices_added = indices_to - indices_from
      indices_removed = indices_from - indices_to

      [].tap do |output|
        output << [:+, indices_added] if indices_added.any?
        output << [:-, indices_removed] if indices_removed.any?
      end
    end

    def self.initialize_analysers(from, to)
       [analyser_for(from), analyser_for(to)]
    end

    def self.analyser_for(ast)
      results = Fast.search '(block (send nil define_type $...) ... $...)', ast
      return [] unless results
      results.each_slice(3).map do |index_name, fields, _|
        IndexAnalyzer.new(index_name, fields)
      end.flatten
    end

    def self.diff(from, to)
      removed = from.fields - to.fields
      added =  to.fields - from.fields
#puts "from",from.fields,"to", to.fields
#puts "added", added.inspect, "removed", removed.inspect
      output = []
      output << [:-, "#{from.index_name}#{describe(removed)}"] if removed.any?
      output << [:+, "#{from.index_name}#{describe(added)}"] if added.any?
      output if output.any?
    end

    def self.describe fields
      fields.map(&method(:field_name)).flatten
    end

    def self.field_name(field)
      if field.type == :send 
        if field.children[2]
          name = field.children[2]
          name.children[0] || name.children[1]
        else
          field.children[1]
        end
      else
        field.children[0].children[-1].children[0]
      end
    end

    class IndexAnalyzer
      MACROS_SUPPORTED = %i[field field_with_crutch witchcraft! crutch include]
      def initialize index_name, fields
        @index_name, @fields = index_name, fields
      end

      def fields
         @fields.children.select do |field|
           if field.type == :block
             field = field.children[0]
           end
           MACROS_SUPPORTED.include?(field.children[1])
         end.compact
      end

      def index_name
        if @index_name.type == :const
          @index_name.loc.expression.source
        elsif @index_name.type == :send
          @index_name.children[0].children.last
        end
      end
    end

    def self.ast(code)
      Parser::CurrentRuby.parse(code)
    end

  end
end
