module TruthSerum
  class Lexer
    def initialize(input)
      @input  = input
      @index  = 0
      @tokens = []
      @buffer = ''
    end

    def lex
      @tokens = []
      lex_line
      @tokens
    end

    def lex_line
      while !eof?
        case peek
        when '"' then lex_quoted_word
        when ':', '+', '-' then lex_symbol
        when ' ' then lex_spaces
        else
          lex_word
        end
      end
    end

    def lex_symbol
      case consume
      when ':' then emit(:colon)
      when '+' then emit(:plus)
      when '-' then emit(:minus)
      else
        raise 'not a symbol'
      end
    end

    def lex_spaces
      consume while peek == ' '
      emit(:space)
    end

    def lex_word
      while !eof?
        case peek
        when ' ', ':', '+', '-' then return emit(:term)
        when '"' then discard
        else
          consume
        end
      end

      emit(:term)
    end

    def lex_quoted_word
      raise 'not in quoted word' unless discard == '"'

      while !eof?
        case peek
        when '\\' then lex_escaped_char
        when '"'
          discard
          break
        else
          consume
        end
      end

      emit(:term)
    end

    def lex_escaped_char
      raise 'not in escaped char' unless discard == '\\'
      return @buffer += '\\' if eof?

      case peek
      when 'r'
        discard
        @buffer += "\r"
      when 'n'
        discard
        @buffer += "\n"
      else # '\\' '"' and everything else is treated literally
        consume
      end
    end

    private

    def eof?
      @index >= @input.length
    end

    def chars_left
      @input.length - @index
    end

    def peek
      return nil if eof?
      @input[@index]
    end

    def consume
      raise 'consume beyond EOF' if eof?

      @buffer += peek
      discard
    end

    def discard
      @index += 1
      @input[@index - 1]
    end

    def emit(type)
      return nil if @buffer == ''

      token = Token.new(type, @buffer)
      @tokens << token
      @buffer = ''
      token
    end
  end
end
