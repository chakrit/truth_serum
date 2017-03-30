# frozen_string_literal: true
require 'test_helper'

module TruthSerum
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
