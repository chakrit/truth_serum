# frozen_string_literal: true

require 'test_helper'

class TruthSerumTest < Minitest::Test
  def test_version
    refute_nil TruthSerum::VERSION
  end

  def test_parse
    result = TruthSerum.parse('hello -world "quoted space" filter:value -a:b')

    assert_equal ['hello', 'quoted space'], result.terms
    assert_equal ['world'],                 result.negative_terms
    assert_equal ({ 'filter' => 'value' }), result.filters
    assert_equal ({ 'a' => 'b' }),          result.negative_filters
  end

  def test_unparse
    result = TruthSerum::Result.new(
      terms:            ['hello', 'quoted space'],
      negative_terms:   ['world'],
      filters:          { 'filter' => 'value' },
      negative_filters: { 'a' => 'b' }
    )

    assert_equal '"quoted space" hello -world filter:value -a:b', TruthSerum.unparse(result)
  end
end
