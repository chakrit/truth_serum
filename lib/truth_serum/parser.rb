module TruthSerum
  class Parser
    def initialize(tokens)
      @tokens = tokens
    end

    def reset
      @result = {
        terms:            [],
        negative_terms:   [],
        filters:          {},
        negative_filters: {},
      }
    end

    def parse
      reset
      parse_line
      @result
    end

    def parse_line
      until eof?
        token = peek

        case
        when token.plus? || token.minus?
          parse_sign
        when token.term?
          parse_term_or_filter
        else
          consume # stray colons and spaces
        end
      end
    end

    def parse_sign
      negate = consume.minus? while peek.plus? || peek.minus?
      if peek.term?
        parse_term_or_filter(negate: negate)
      else
        nil
      end
    end

    def parse_term_or_filter(negate: false)
      term   = ''
      value  = ''

      # first portion of text
      term = consume.text
      return emit_term(term, negate: negate) unless peek.colon?

      # initial `:` separator
      consume

      # the rest becomes value (including successive `:`s)
      value += consume.text while peek.colon? || peek.term?

      emit_filter(term, value, negate: negate)
    end

    private

    def emit_term(term, negate: false)
      @result[:terms]          << term unless negate
      @result[:negative_terms] << term if negate
    end

    def emit_filter(key, value, negate: false)
      @result[:filters][key]          = value unless negate
      @result[:negative_filters][key] = value if negate
    end

    def eof?
      peek.is_a?(NilToken)
    end

    def peek
      @tokens[0] || NilToken.new
    end

    def consume
      @tokens.shift || NilToken.new
    end
  end
end
