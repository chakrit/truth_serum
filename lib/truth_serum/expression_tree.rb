# frozen_string_literal: true

module TruthSerum
  PRECEDENCE_TABLE = {
    negate: 0,
    and: 1,
    or: 2
  }.freeze

  class ExpressionTree < StateMachine
    def parse
      execute
    end

    # convert result stream to hash
    def execute
      @default_operator = Token.new(:conj, :and)
      @negate = false
      @operands = []
      @conjunctions = []

      super
      @operands[0]
    end

    state :start do
      token = peek
      case
      when token.nil?
        :end
      when token.plus? || token.minus?
        :parse_modifier
      when token.colon? || token.space?
        consume # ignored
        :start
      when token.term?
        :parse_term_or_filter
      when token.conj? # (treat conjunction as term if state is first state or previous state is conjunction)
        :parse_term
      end
    end

    state :parse_conjunction do
      token = peek
      case
      when token.nil?
        emit_eof
        :end
      when token.plus?, token.term?, token.minus?
        emit_operator(@default_operator)
        :start
      when token.colon?, token.space? # ignored
        consume
        :parse_conjunction
      when token.conj?
        consume
        # if nil after conjunction then conjunction should treat as 'term' also we need conjunction between term.
        if peek.nil?
          rewind
          emit_operator(@default_operator)
          :parse_term
        else
          emit_operator(token)
        end
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
      token = consume

      # handle special case for conjunction such as
      # "_AND_ hello world",
      # "hello AND AND world",
      # _AND_ should treat as term not conjunction
      if token.conj?
        emit_term(token.text.to_s.upcase)
      else
        emit_term(token.text)
      end
      :parse_conjunction
    end

    state :parse_filter do
      @filter_key = consume.text
      :parse_filter_separator
    end

    state :parse_filter_separator do
      token = peek
      case
      when token&.colon?
        consume
        :parse_filter_separator
      when token&.term?
        :parse_filter_value
      else
        emit_term(@filter_key)
        @filter_key = nil
        :parse_conjunction
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
        :parse_conjunction
      end
    end

    private

    def emit_term(term)
      record = [:term, term]
      record = [:negate, record] if @negate
      @negate = false

      @operands << record
    end

    def emit_filter(key, value)
      record = [:filter, key, value]
      record = [:negate, record] if @negate
      @negate = false

      @operands << record
    end

    def emit_operator(token)
      compose_operand until higher_precedence? token.text
      @conjunctions << token.text
    end

    def emit_eof
      compose_operand until @conjunctions.empty?
    end

    def compose_operand
      rhs_operand = @operands.pop
      lhs_operand = @operands.pop
      operator = @conjunctions.pop
      @operands << [operator, lhs_operand, rhs_operand]
    end

    def higher_precedence?(type)
      @conjunctions.empty? || PRECEDENCE_TABLE[type] < PRECEDENCE_TABLE[@conjunctions.last]
    end
  end
end
