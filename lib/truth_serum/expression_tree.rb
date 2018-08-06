# frozen_string_literal: true

module TruthSerum
  PRECEDENCE_TABLE = {
    and: 1,
    or: 2
  }.freeze

  class ExpressionTree < StateMachine
    def parse
      execute
    end

    # convert result stream to hash
    def execute
      @default_operator = Token.new(:operator, :and)
      @negate = false
      @operands = []
      @operators = []

      super
      @operands[0]
    end

    state :start do
      token = peek
      case
      when token.nil?
        emit_eof
        :end
      when token.plus? || token.minus?
        :parse_modifier
      # (ignore operator if state is first state or previous state is operator)
      when token.colon? || token.space? || token.operator?
        consume # ignored
        :start
      when token.term?
        :parse_term_or_filter
      end
    end

    state :parse_operator do
      token = peek
      case
      when token.nil?
        emit_eof
        :end
      when token.colon?, token.space? # ignored
        consume
        :parse_operator
      when token.plus?, token.term?, token.minus?
        emit_operator(@default_operator)
        :start
      when token.operator?
        consume
        # if nil after operator then operator should ignored it.
        emit_operator(token) unless peek.nil?
        :start
      else
        raise "token should be operator (found: #{token.type})"
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
      emit_term(token.text)
      :parse_operator
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
        :parse_operator
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
        :parse_operator
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
      operator = token.text.downcase.to_sym # ex. convert 'AND' to :and.
      compose_operand until higher_precedence? operator
      @operators << operator
    end

    def emit_eof
      compose_operand until @operators.empty? || @operands.length <= 1
    end

    def compose_operand
      rhs_operand = @operands.pop
      lhs_operand = @operands.pop
      operator = @operators.pop
      @operands << [operator, lhs_operand, rhs_operand]
    end

    def higher_precedence?(type)
      @operators.empty? || PRECEDENCE_TABLE[type] < PRECEDENCE_TABLE[@operators.last]
    end
  end
end
