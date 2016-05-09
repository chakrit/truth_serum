require 'test_helper'

module TruthSerum
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
  end
end
