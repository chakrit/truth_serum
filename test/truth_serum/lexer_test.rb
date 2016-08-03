require 'test_helper'

module TruthSerum
  class LexerTest < Minitest::Test
    def test_lex
      LEX_TESTS.each do |input, tokens|
        assert_lex input, tokens
      end
    end

    private

    def assert_lex(input, stream)
      result = Lexer.new(input).lex.flat_map do |token|
        [token.type, token.text]
      end

      assert_equal stream, result, "input string: `#{input}` was not lex-ed correctly."
    end
  end
end
