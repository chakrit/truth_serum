# frozen_string_literal: true
require 'test_helper'

module TruthSerum
  UNPARSE_TESTS = {
    'asdf'         => { terms: ['asdf'] },
    '-asdf'        => { negative_terms: ['asdf'] },
    '"a b"'        => { terms: ['a b'] },
    'a+b'          => { terms: ['a+b'] },
    'a:b'          => { filters: { 'a' => 'b' } },
    '-a:b'         => { negative_filters: { 'a' => 'b' } },
    '"s s":"x x"'  => { filters: { 's s' => 'x x' } },
    'term a:b'     => { terms: ['term'], filters: { 'a' => 'b' } },
    '-term -a:b'   => { negative_terms: ['term'], negative_filters: { 'a' => 'b' } },
    'a::::b'       => { filters: { 'a' => ':::b' } },
    'a:bb:c'       => { filters: { 'a' => 'bb:c' } },
    'a:2016-01-02' => { filters: { 'a' => '2016-01-02' } }
  }.freeze

  class ResultTest < Minitest::Test
    def test_initialize
      result = Result.new(
        terms:            ['zxcv'],
        negative_terms:   ['asdf'],
        filters:          { hello: 'world' },
        negative_filters: { earth: '616' }
      )

      assert result.terms            == ['zxcv']
      assert result.negative_terms   == ['asdf']
      assert result.filters          == { hello: 'world' }
      assert result.negative_filters == { earth: '616' }
    end

    def test_reconstruct_query
      UNPARSE_TESTS.each do |key, value|
        result = Result.new(
          terms:            value[:terms],
          negative_terms:   value[:negative_terms],
          filters:          value[:filters],
          negative_filters: value[:negative_filters]
        )

        assert_equal key, result.reconstruct_query
      end
    end
  end
end
