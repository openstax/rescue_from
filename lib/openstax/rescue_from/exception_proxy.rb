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
        RescueFrom.friendly_status_messages[status]
      end

      def extras
        @extras ||= RescueFrom.exception_extra(exception.class.name).call(exception)
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
        @status ||= RescueFrom.exception_status_code(exception.class.name)
      end

      def status_code
        @status_code ||= RescueFrom.status_code(status)
      end

      def notify?
        RescueFrom.notifies_exception?(name)
      end
    end
  end
end
