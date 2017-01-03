# frozen_string_literal: true
module TruthSerum
  class Result
    attr_accessor :terms, :negative_terms, :filters, :negative_filters

    def initialize(terms:, negative_terms:, filters:, negative_filters:)
      @terms            = terms
      @negative_terms   = negative_terms
      @filters          = filters
      @negative_filters = negative_filters
    end

    def reconstruct_query
      result = []
      result += reconstruct_terms(terms)                      if terms
      result += negate(reconstruct_terms(negative_terms))     if negative_terms
      result += reconstruct_filters(filters)                  if filters
      result += negate(reconstruct_filters(negative_filters)) if negative_filters

      result.compact.join(' ').strip
    end

    private

    def reconstruct_terms(terms)
      quotables, others = terms.partition { |t| should_quote(t) }
      quotables = quotables.map { |t| quote_term(t) }

      [quotables, others].flatten
    end

    def reconstruct_filters(filters)
      filters.map do |key, value|
        key   = quote_term(key)   if should_quote(key)
        value = quote_term(value) if should_quote(value)

        "#{key}:#{value}"
      end
    end

    def negate(terms)
      terms.map { |t| "-#{t}" }
    end

    def should_quote(term)
      term =~ /[ \"\r\n]/
    end

    def quote_term(term)
      term = term.gsub(/\r/, '\r')
                 .gsub(/\n/, '\n')
                 .gsub(/\\/, '\\\\')

      "\"#{term}\""
    end
  end
end
