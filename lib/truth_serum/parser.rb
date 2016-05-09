module TruthSerum
  def debug(key, value)
    puts "#{key}: #{value}"
  end

  class Parser
    def initialize(tokens)
      @tokens = tokens
      @result = {terms: [], filters: {}}
    end

    def parse
      @result = {terms: [], filters: {}}
      parse_line
      @result
    end

    def parse_line
      while !eof?
        debug 'parse', 'line'

        case
        when peek.term?
          parse_term
        when peek.colon? && @result[:terms].length > 0 # `term:` situation
          parse_filter

        else
          consume # ignore stray colons and spaces
        end
      end
    end

    def parse_term
      debug 'parse', 'term'
      @result[:terms] << consume.text
    end

    def parse_filter
      debug 'parse', 'filter'
      key = @result[:terms].pop
      value = parse_filter_value
      @result[:filters][key.to_sym] = value
    end

    def parse_filter_value
      debug 'parse', 'filter_value'
      consume while peek.colon? # eat the separator and any duplicates
      consume.text
    end

    private

    def eof?
      @tokens.length <= 0
    end

    def peek
      return nil if eof?
      @tokens[0]
    end

    def consume
      raise 'no more tokens' if eof?
      @tokens.shift
    end
  end
end
