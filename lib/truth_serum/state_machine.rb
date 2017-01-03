module TruthSerum
  class StateMachine
    class << self
      def states
        @states ||= {}
      end

      def state(name, &block)
        @states ||= {}
        @states[name] = block
      end
    end

    attr_accessor :debug

    def initialize(input)
      @input    = input
      @states   = self.class.states
      @position = 0
      @result   = []
    end

    def execute
      @position = 0
      @result = []

      state = :start
      loop do
        puts "#{self.class.name}: #{state}" if debug

        next_state = instance_eval(&@states[state])
        case
        when next_state == :end
          break
        when !next_state.is_a?(Symbol)
          raise "#{state.inspect} did not return the next state."
        when !@states.key?(next_state)
          raise "#{state.inspect} refers to undefined #{next_state.inspect} state."
        end

        state = next_state
      end

      @result
    end

    protected

    def peek
      @input[@position]
    end

    def consume
      result = @input[@position]
      @position += 1
      result
    end

    def rewind
      @position -= 1
    end

    def eof?
      @position >= @input.length
    end

    def emit(value)
      puts "#{self.class.name}: << #{value.inspect}" if debug
      @result << value
    end
  end
end
