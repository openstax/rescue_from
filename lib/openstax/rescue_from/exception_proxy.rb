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
        @cause ||= exception.cause
      end

      def backtrace
        @backtrace ||= cause.blank? ? first_backtrace_line : all_backtrace_lines
      end

      def all_backtrace_lines
        @all_backtrace_lines ||= exception.backtrace.join("\n")
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
