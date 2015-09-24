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
        @error_id ||= Error.id
      end

      def message
        @message ||= exception.message
      end

      def friendly_message
        config.friendly_status_messages[status]
      end

      def dns_name
        @dns_name ||= Resolv.getname(listener.request.remote_ip) rescue 'unknown'
      end

      def extras
        @extras ||= if extras_proc = config.exception_extras[exception.class.name]
                      extras_proc.call(exception)
                    else
                      "{}"
                    end
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
        @status ||= config.exception_status_codes[exception.class.name]
      end

      def status_code
        @status_code ||= Rack::Utils.status_code(status)
      end

      def notify?
        not config.non_notifying_exceptions.include?(name)
      end

      private
      def config
        RescueFrom.configuration
      end
    end
  end
end
