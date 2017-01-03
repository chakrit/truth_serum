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
