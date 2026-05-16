require_relative 'base'

module API
  module Errors
    class Validation < Base
      def initialize(message)
        super(message, status: 422)
      end
    end
  end
end
