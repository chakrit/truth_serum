# frozen_string_literal: true

require 'truth_serum/version'
require 'truth_serum/result'
require 'truth_serum/token'
require 'truth_serum/state_machine'
require 'truth_serum/lexer'
require 'truth_serum/parser'
require 'truth_serum/expression_tree'

module TruthSerum
  module_function

  def parse(line)
    Result.new(**Parser.new(Lexer.new(line).lex).parse)
  end

  def unparse(hash)
    result = if hash.is_a?(Result)
               hash
             else
               Result.new(
                 terms:            hash[:terms],
                 negative_terms:   hash[:negative_terms],
                 filters:          hash[:filters],
                 negative_filters: hash[:negative_filters]
               )
             end

    result.reconstruct_query
  end
end
