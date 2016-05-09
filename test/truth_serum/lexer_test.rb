require 'test_helper'

module TruthSerum
  class LexerTest < Minitest::Test
    TESTS = {
      'word'          => [:term, 'word'],
      'space  space'  => [:term, 'space', :space, '  ', :term, 'space'],
      '::++--'        => [:colon, ':', :colon, ':', :plus, '+', :plus, '+', :minus, '-', :minus, '-'],
      '"quote"'       => [:term, 'quote'],
      '"unended'      => [:term, 'unended'],
      'ending"'       => [:term, 'ending'],
      'mid"dle'       => [:term, 'middle'],
      '"space quote"' => [:term, 'space quote'],
      '":sym+quote-"' => [:term, ':sym+quote-'],
      'split:split'   => [:term, 'split', :colon, ':', :term, 'split'],
      '-a:b+a:b'      => [:minus, '-', :term, 'a', :colon, ':', :term, 'b', :plus, '+', :term, 'a', :colon, ':', :term, 'b'],
      '"\r\n\a\b\""'  => [:term, "\r\nab\""],
      'a "b b"'       => [:term, 'a', :space, ' ', :term, 'b b'],
      '-a+ "h h"-'    => [:minus, '-', :term, 'a', :plus, '+', :space, ' ', :term, 'h h', :minus, '-'],
      '-"\r :"zxcv'   => [:minus, '-', :term, "\r :", :term, 'zxcv'],
    }

    def test_lex
      TESTS.each do |input, tokens|
        assert_lex input, tokens
      end
    end

    private

    def assert_lex(input, stream)
      result  = Lexer.new(input).lex.flat_map do |token|
        [token.type, token.text]
      end

      assert_equal stream, result, "input string: `#{input}` was not lex-ed correctly."
    end
  end
end
