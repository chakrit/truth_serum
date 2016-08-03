$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'truth_serum'

require 'minitest'
require 'minitest/hell'
require 'minitest/pride'
require 'minitest/autorun'

class Minitest::Test
  parallelize_me!
end
