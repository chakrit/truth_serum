require 'test_helper'

module BooleanParser
  class TokenTest < Minitest::Test
    def test_initialize
      token = Token.new(:term, 'asdf')
      assert_equal :term,  token.type
      assert_equal 'asdf', token.text
    end

    def test_valid
      refute Token.new(:invalid, 'test').valid?
      refute Token.new(:term, nil).valid?
      refute Token.new(:term, '').valid?

      assert Token.new(:term, 'abc').valid?
      assert Token.new(:plus, '+').valid?
      assert Token.new(:plus, 'not really').valid?
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
