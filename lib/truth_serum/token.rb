# frozen_string_literal: true
module TruthSerum
  class Token
    VALID_TYPES = [
      :term,
      :colon,
      :space,
      :plus,
      :minus
    ].freeze

    attr_accessor :type, :text

    class << self
      def from_array(arr)
        arr.map do |type, text|
          Token.new(type, text)
        end
      end
    end

    def initialize(type, text)
      @type = type
      @text = text
    end

    VALID_TYPES.each do |type|
      define_method "#{type}?" do
        @type == type
      end
    end
  end
end
