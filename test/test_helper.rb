# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'truth_serum'
require 'fuzzer'

require 'minitest'
require 'minitest/hell'
require 'minitest/pride'
require 'minitest/autorun'

module Minitest
  class Test
    parallelize_me!

    protected

    def fuzz(vocab)
      Fuzzer.new(vocab).fuzz do |line|
        yield line
      end
    end
  end
end
