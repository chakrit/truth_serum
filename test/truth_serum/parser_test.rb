require 'test_helper'

module TruthSerum
  class ParserTest < Minitest::Test
    TESTS = {
      'asdf'         => { terms: ['asdf'] },
      '-asdf'        => { negative_terms: ['asdf'] },
      '"quote"'      => { terms: ['quote'] },
      '-"quote"'     => { negative_terms: ['quote'] },
      'a:b'          => { filters: { 'a' => 'b' } },
      '-a:b'         => { negative_filters: { 'a' => 'b' } },
      'term a:b'     => { terms: ['term'], filters: { 'a' => 'b' } },
      '-term-a:b'    => { negative_terms: ['term'], negative_filters: { 'a' => 'b' } },
      'a::::b'       => { filters: { 'a' => ':::b' } },
      'a:bb:c'       => { filters: { 'a' => 'bb:c' } },
      'a:2016-01-02' => { filters: { 'a' => '2016-01-02' } },
    }

    def test_parse
      TESTS.each do |input, expects|
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
