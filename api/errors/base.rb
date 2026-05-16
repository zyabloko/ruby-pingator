module API
  module Errors
    class Base < StandardError
      attr_reader :status

      def initialize(message, status: 500)
        super(message)
        @status = status
      end
    end
  end
end
