# frozen_string_literal: true
require 'test_helper'

module TruthSerum
  class StateMachineTest < Minitest::Test
    class Simple < StateMachine
      state :start do
        :emit
      end

      state :emit do
        emit(:correct)
        :end
      end
    end

    class Branching < StateMachine
      state :start do
        if eof?
          :end
        else
          case peek
          when /[a-z]/ then :alpha
          when /[0-9]/ then :num
          end
        end
      end

      state :alpha do
        emit([:alpha, consume])
        :start
      end

      state :num do
        emit([:num, consume])
        :start
      end
    end

    class Looping < StateMachine
      state :start do
        :loop
      end

      state :loop do
        @count ||= 0
        @count += 1

        emit(@count)
        if @count == 5
          :end
        else
          :loop
        end
      end
    end

    class Rewinding < StateMachine
      state :start do
        case peek
        when nil
          :end
        when 'x'
          rewind
          :upcase
        else
          emit(consume)
          :start
        end
      end

      state :upcase do
        emit(consume.upcase)
        consume # 'x' marker
        :start
      end
    end

    class EOFCheck < StateMachine
      state :start do
        if peek.nil?
          :end
        else
          emit(consume)
          :start
        end
      end
    end

    class BadMachine < StateMachine
      state :start do
        case consume
        when 'n' then :return_nil
        when 'w' then :return_wrong
        end
      end

      state :return_nil do
        nil
      end

      state :return_wrong do
        :wrong_state
      end
    end

    TESTS = [
      { machine: Simple,    input: '',     output: [:correct] },
      { machine: Branching, input: 'ab',   output: [[:alpha, 'a'], [:alpha, 'b']] },
      { machine: Branching, input: '12',   output: [[:num, '1'], [:num, '2']] },
      { machine: Branching, input: 'a1b2', output: [[:alpha, 'a'], [:num, '1'], [:alpha, 'b'], [:num, '2']] },
      { machine: Looping,   input: '',     output: [1, 2, 3, 4, 5] },
      { machine: Rewinding, input: 'abxc', output: %w(a b B c) },
      { machine: EOFCheck,  input: '123',  output: %w(1 2 3) }
    ].freeze

    ERRORS = [
      { machine: BadMachine, input: 'n', error: ':return_nil did not return the next state.' },
      { machine: BadMachine, input: 'w', error: ':return_wrong refers to undefined :wrong_state state.' }
    ].freeze

    def test_state_machines
      TESTS.each do |testcase|
        machine = testcase[:machine].new(testcase[:input])
        assert_equal testcase[:output], machine.execute, testcase.inspect
      end
    end

    def test_bad_state_machine
      ERRORS.each do |testcase|
        err = assert_raises ::RuntimeError do
          machine = testcase[:machine].new(testcase[:input])
          machine.execute
        end

        assert_equal testcase[:error], err.message
      end
    end
  end
end
