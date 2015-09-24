module OpenStax
  module RescueFrom
    class Logger
      attr_reader :wrapped

      def initialize(wrapped)
        @wrapped = wrapped
      end

      def record_system_error!(prefix = "An exception occurred")
        config.logger.error("#{prefix}: #{wrapped.name} [#{wrapped.error_id}] " +
                            "<#{wrapped.message}> #{wrapped.extras}\n\n" +
                            "#{wrapped.backtrace}")

        record_system_error_recursively!
      end

      private
      def record_system_error_recursively!
        if wrapped.cause
          @wrapped = WrappedException.new(wrapped.cause)
          record_system_error!("Exception cause")
        end
      end

      def config
        RescueFrom.configuration
      end
    end
  end
end
