module OpenStax
  module RescueFrom
    class Configuration

      attr_accessor :raise_exceptions, :system_logger

      def initialize
        @raise_exceptions = false
        @system_logger = Rails.logger
      end
    end
  end
end
