# frozen_string_literal: true
require 'test_helper'

module TruthSerum
  class ParserTest < Minitest::Test
    def test_parse
      PARSE_TESTS.each do |input, expects|
        result = parse(input)
        expects.each do |key, value|
          assert_equal value, result[key], "invalid #{key} result for `#{input}` search"
        end
      end
    end

    private

    def parse(line)
      Parser.new(Lexer.new(line).lex).parse
    end
  end
end
