module OpenStax
  module RescueFrom
    class ExceptionProxy
      attr_reader :exception

      def initialize(exception)
        @exception = exception
      end

      def name
        @name ||= exception.class.name
      end

      def error_id
        @error_id ||= RescueFrom.generate_id
      end

      def message
        @message ||= exception.message
      end

      def friendly_message
        RescueFrom.friendly_message(self)
      end

      def extras
        @extras ||= RescueFrom.extras_proc(name).call(exception)
      end

      def cause
        @cause ||= exception.cause if exception.respond_to?(:cause)
      end

      def logger_backtrace
        @backtrace ||= exception.backtrace&.join("\n")
      end

      def first_backtrace_line
        @first_backtrace_line ||= exception.backtrace&.first
      end

      def status
        @status ||= RescueFrom.status(name)
      end

      def status_code
        @status_code ||= RescueFrom.http_code(status)
      end

      def sorry
        return @sorry unless @sorry.nil?

        @sorry = RescueFrom.sorry(name)
      end
    end
  end
end
