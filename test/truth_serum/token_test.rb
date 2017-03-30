# frozen_string_literal: true

require 'test_helper'

module TruthSerum
  class TokenTest < Minitest::Test
    def test_initialize
      token = Token.new(:term, 'asdf')
      assert_equal :term,  token.type
      assert_equal 'asdf', token.text
    end

    def test_from_array
      stream = [
        [:term, 'term'],
        [:colon, ':'],
        [:minus, '-']
      ]

      tokens = Token.from_array(stream)
      assert_equal :term,  tokens[0].type
      assert_equal 'term', tokens[0].text
      assert_equal :colon, tokens[1].type
      assert_equal ':',    tokens[1].text
      assert_equal :minus, tokens[2].type
      assert_equal '-',    tokens[2].text
    end

    def test_type_query
      Token::VALID_TYPES.each do |type|
        token = Token.new(type, 'test')
        assert token.send("#{type}?")

        (Token::VALID_TYPES - [type]).each do |other_type|
          refute token.send("#{other_type}?")
        end
      end
    end
  end
end
