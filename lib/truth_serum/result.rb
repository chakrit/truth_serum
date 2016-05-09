module TruthSerum
  class Result
    attr_accessor :terms, :negative_terms, :filters, :negative_filters

    def initialize(terms:, negative_terms:, filters:, negative_filters:)
      @terms            = terms
      @negative_terms   = negative_terms
      @filters          = filters
      @negative_filters = negative_filters
    end
  end
end
