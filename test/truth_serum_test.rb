require 'test_helper'

class TruthSerumTest < Minitest::Test
  def test_version
    refute_nil TruthSerum::VERSION
  end

  def test_parse
    result = TruthSerum.parse('hello -world "quoted space" filter:value -a:b')

    assert_equal ['hello', 'quoted space'], result.terms
    assert_equal ['world'],                 result.negative_terms
    assert_equal ({ "filter" => "value" }), result.filters
    assert_equal ({ "a" => "b" }),          result.negative_filters
  end
end
