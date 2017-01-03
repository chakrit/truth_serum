# frozen_string_literal: true
module TruthSerum
  class Lexer < StateMachine
    def lex
      execute
    end

    state :start do
      case peek
      when nil then :end
      when ' ' then :lex_space
      when ':', '+', '-' then :lex_symbol
      when '"' then :lex_quoted_term
      else
        :lex_term
      end
    end

    state :lex_space do
      case peek
      when ' '
        append(consume)
        :lex_space
      else
        emit(:space)
        :start
      end
    end

    state :lex_symbol do
      case append(consume)
      when ':' then emit(:colon)
      when '+' then emit(:plus)
      when '-' then emit(:minus)
      else
        raise 'not a symbol'
      end
      :start
    end

    state :lex_term do
      case peek
      when ' ', ':', nil
        emit(:term)
        :start
      when '"'
        consume # ignored
        :lex_term
      else
        append(consume)
        :lex_term
      end
    end

    state :lex_quoted_term do
      raise 'not in quoted term' unless consume == '"'
      :lex_inside_quoted_term
    end

    state :lex_inside_quoted_term do
      case peek
      when nil
        emit(:term)
        :start
      when '\\'
        :lex_quoted_char
      when '"'
        consume
        emit(:term)
        :start
      else
        append(consume)
        :lex_inside_quoted_term
      end
    end

    state :lex_quoted_char do
      raise 'not in quoted char' unless consume == '\\'

      case char = consume
      when 'r'
        append("\r")
      when 'n'
        append("\n")
      else # '\\' '"' and everything else is passed verbatim
        append(char)
      end

      :lex_inside_quoted_term
    end

    private

    def append(ch)
      @buffer ||= ''
      @buffer += ch
      ch
    end

    def emit(type)
      super(Token.new(type, @buffer))
      @buffer = nil
    end
  end
end
