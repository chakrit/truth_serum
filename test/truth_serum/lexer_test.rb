# frozen_string_literal: true

require 'test_helper'

module TruthSerum
  LEX_FUZZ_CHARS = "abc+-:\"\\ \r\n\t"

  LEX_TESTS = {
    'word'          => [:term, 'word'],
    'space  space'  => [:term, 'space', :space, '  ', :term, 'space'],
    '::++--'        => [:colon, ':', :colon, ':', :plus, '+', :plus, '+', :minus, '-', :minus, '-'],
    'same+word'     => [:term, 'same+word'],
    '"quote"'       => [:term, 'quote'],
    '"unended'      => [:term, 'unended'],
    'ending"'       => [:term, 'ending'],
    'mid"dle'       => [:term, 'middle'],
    '"space quote"' => [:term, 'space quote'],
    '":sym+quote-"' => [:term, ':sym+quote-'],
    'split:split'   => [:term, 'split', :colon, ':', :term, 'split'],
    '-a:b+a:b'      => [:minus, '-', :term, 'a', :colon, ':', :term, 'b+a', :colon, ':', :term, 'b'],
    '"\r\n\a\b\""'  => [:term, "\r\nab\""],
    'a:b b'         => [:term, 'a', :colon, ':', :term, 'b', :space, ' ', :term, 'b'],
    'a "b b"'       => [:term, 'a', :space, ' ', :term, 'b b'],
    '-a+ "h h"-'    => [:minus, '-', :term, 'a+', :space, ' ', :term, 'h h', :minus, '-'],
    '-"\r :"zxcv'   => [:minus, '-', :term, "\r :", :term, 'zxcv'],
    '""eiei""'      => [:term, '', :term, 'eiei'],
    '""""'          => [:term, '', :term, ''],
    '"\"'           => [:term, '"'],
    '"\""\"'        => [:term, '"', :term, '\\']
  }.freeze

  class LexerTest < Minitest::Test
    def test_lex
      LEX_TESTS.each do |input, tokens|
        assert_lex input, tokens
      end
    end

    if ENV['SLOWFUZZ']
      def test_lex_fuzzy # ensure we never puke on input, ever
        fuzz(LEX_FUZZ_CHARS) do |line|
          refute_nil lex(line)
        end
      end
    end

    private

    def lex(input)
      Lexer.new(input).lex
    end

    def assert_lex(input, stream)
      result = lex(input).flat_map do |token|
        [token.type, token.text]
      end

      assert_equal stream, result, "input string: `#{input}` was not lex-ed correctly."
    end
  end
end
