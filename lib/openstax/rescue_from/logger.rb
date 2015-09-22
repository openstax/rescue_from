module OpenStax
  module RescueFrom
    class Logger
      attr_reader :exception

      def initialize(exception:)
        @exception = exception
      end

      def record_rails_error!
        Rails.logger.error("#{exception.header}: #{exception.name} " +
                          "[#{exception.error_id}] <#{exception.message}> " +
                           "#{exception.extras}\n\n#{exception.backtrace}")

        record_rails_error_recursively!
      end

      private
      def record_rails_error_recursively!
        if exception.cause
          @exception = ExceptionWrapper.new(exception: exception.cause)
          record_rails_error!
        end
      end
    end
  end
end
