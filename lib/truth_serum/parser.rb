# frozen_string_literal: true
module TruthSerum
  class Parser < StateMachine
    def parse
      execute
    end

    # convert result stream to hash
    def execute
      @negate = false
      @hash = {
        terms:            [],
        negative_terms:   [],
        filters:          {},
        negative_filters: {}
      }

      super
      @hash
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
      token = peek
      case
      when token && token.colon?
        consume
        :parse_filter_separator
      when token && token.term?
        :parse_filter_value
      else
        emit_term(@filter_key)
        @filter_key = nil
        :start
      end
    end

    state :parse_filter_value do
      case
      when !peek.nil? && (peek.term? || peek.colon?)
        # consecutive `:` inside value part are treated literally
        @filter_value ||= ''
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
      type = @negate ? :negative_terms : :terms
      @negate = false

      if @hash.key?(type)
        @hash[type] << term
      else
        @hash[type] = [term]
      end
    end

    def emit_filter(key, value)
      type = @negate ? :negative_filters : :filters
      @negate = false

      if @hash.key?(type)
        @hash[type][key] = value
      else
        @hash[type] = { key => value }
      end
    end
  end
end
