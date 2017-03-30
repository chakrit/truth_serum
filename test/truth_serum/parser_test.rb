# frozen_string_literal: true
require 'test_helper'

module TruthSerum
  PARSE_FUZZ_TOKENS = [
    [:term, 'term'],
    # [:term, ''],
    [:term, 'c'],
    [:colon, ':'],
    [:space, ' '],
    # [:space, ''],
    [:space, "\n"],
    # [:space, "\r"],
    [:space, "\t"],
    [:plus, '+'],
    [:plus, '-'],
  ]

  PARSE_TESTS = {
    'asdf'         => { terms: ['asdf'] },
    '-asdf'        => { negative_terms: ['asdf'] },
    '"quote"'      => { terms: ['quote'] },
    '-"quote"'     => { negative_terms: ['quote'] },
    'a:b'          => { filters: { 'a' => 'b' } },
    ':badcolons'   => { terms: ['badcolons'] },
    'badcolons:'   => { terms: ['badcolons'] },
    'spaceafter: ' => { terms: ['spaceafter'] },
    'colonafter::' => { terms: ['colonafter'] },
    'colnspcaf:: ' => { terms: ['colnspcaf'] },
    'abc:-'        => { terms: ['abc'] },
    '-a:b'         => { negative_filters: { 'a' => 'b' } },
    '"s s":"x x"'  => { filters: { 's s' => 'x x' } },
    'term a:b'     => { terms: ['term'], filters: { 'a' => 'b' } },
    '-term-a:b'    => { negative_terms: [], negative_filters: { 'term-a' => 'b' } },
    'a::::b'       => { filters: { 'a' => 'b' } },
    'a:":b":"b:"'  => { filters: { 'a' => ':b:b:' } },
    'a:bb:c'       => { filters: { 'a' => 'bb:c' } },
    'a:2016-01-02' => { filters: { 'a' => '2016-01-02' } },
    'name:""ei""'  => { terms: [], filters: { 'name' => 'ei' } }
  }.freeze

  class ParserTest < Minitest::Test
    def test_parse
      PARSE_TESTS.each do |input, expects|
        assert_parse input, expects
      end
    end

    def test_parse_fuzzy
      tokens = Token.from_array(PARSE_FUZZ_TOKENS)
      fuzz(tokens) do |stream|
        refute_nil parse(stream)
      end
    end

    private

    def lex(line)
      Lexer.new(line).lex
    end

    def parse(line)
      Parser.new(line).parse
    end

    def assert_parse(line, expects)
      result = parse(lex(line))
      expects.each do |key, value|
        assert_equal value, result[key], "invalid #{key} result for `#{line}` search"
      end
    end
  end
end
