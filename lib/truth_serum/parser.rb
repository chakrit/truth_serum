module TruthSerum
  class Parser < StateMachine
    def parse
      execute
    end

    # convert result stream to hash
    def execute
      result = {
        terms:            [],
        negative_terms:   [],
        filters:          {},
        negative_filters: {},
      }

      stream = super
      while stream.length > 0
        result = merge_result(result, stream.shift)
      end

      result
    end

    state :start do
      token = peek
      case
      when token.nil?
        :end
      when token.plus? || token.minus?
        :parse_modifier
      when token.term?
        :parse_term_or_filter
      when token.colon? || token.space?
        consume # ignored
        :start
      end
    end

    state :parse_modifier do
      token = consume
      case
      when token.plus?
        @negate = false
      when token.minus?
        @negate = true
      else
        raise 'not a modifier'
      end
      :start
    end

    state :parse_term_or_filter do
      start_token = consume
      mid_token = peek
      raise 'not term or filter' unless start_token.term?

      rewind
      if mid_token.nil? || !mid_token.colon?
        :parse_term
      else # mid_token.colon? == true
        :parse_filter
      end
    end

    state :parse_term do
      emit_term(consume.text)
      :start
    end

    state :parse_filter do
      @filter_key = consume.text
      :parse_filter_separator
    end

    state :parse_filter_separator do
      case
      when peek.nil? # dangling colon at the end, treat key as single term
        emit_term(@filter_key)
        @filter_key = nil
        :start
      when peek.colon?
        consume
        :parse_filter_separator
      when peek.term?
        :parse_filter_value
      else
        raise 'malformed filter!!!'
      end
    end

    state :parse_filter_value do
      case
      when !peek.nil? && (peek.term? || peek.colon?)
        # consecutive `:` inside value part are treated literally
        @filter_value ||= ""
        @filter_value += consume.text
        :parse_filter_value
      else
        emit_filter(@filter_key, @filter_value)
        @filter_key, @filter_value = nil, nil
        :start
      end
    end

    private

    def emit_term(term)
      type = if @negate then :negative_terms else :terms end
      @negate = false

      emit({ type => [term] })
    end

    def emit_filter(key, value)
      type = if @negate then :negative_filters else :filters end
      @negate = false

      emit({ type => { key => value } })
    end

    # simplified 1-deep merge
    def merge_result(x, y)
      result = x.merge({})
      y.each do |key, value|
        if result.key?(key)
          if value.is_a?(Hash)
            result[key] = result[key].merge(value)
          elsif value.is_a?(Array)
            result[key] = result[key] + value
          end
        else
          result[key] = value
        end
      end

      result
    end
  end
end
