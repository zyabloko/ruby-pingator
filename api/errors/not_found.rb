require_relative 'base'

module API
  module Errors
    class NotFound < Base
      def initialize(message)
        super(message, status: 404)
      end
    end
  end
end
