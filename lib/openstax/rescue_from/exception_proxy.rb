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
        RescueFrom.friendly_message(status)
      end

      def extras
        @extras ||= RescueFrom.extras_proc(name).call(exception)
      end

      def cause
        @cause ||= if exception.respond_to?(:cause) && exception.cause
                     ExceptionCauseProxy.new(exception.cause)
                   else
                     nil
                   end
      end

      def logger_backtrace
        @backtrace ||= exception.backtrace.join("\n")
      end

      def first_backtrace_line
        @first_backtrace_line ||= exception.backtrace.first
      end

      def status
        @status ||= RescueFrom.status(name)
      end

      def status_code
        @status_code ||= RescueFrom.http_code(status)
      end
    end
  end
end
