module OpenStax
  module RescueFrom
    class WrappedException
      attr_reader :exception, :listener

      def initialize(exception:, listener: nil, logger: Logger.new(wrapped: self))
        @exception = exception
        @listener = listener
        @logger = logger
        @notifier = config.notifier
      end

      def handle_exception!
        logger.record_system_error!
        send_notifying_exceptions

        if config.raise_exceptions
          raise exception
        else
          listener_response
        end
      end

      def header
        @header ||= cause.blank? ? 'An exception occurred' : 'Exception cause'
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
        @backtrace ||= if cause.blank?
                         exception.backtrace.join("\n")
                       else
                         exception.backtrace.first
                       end
      end

      def status
        @status ||= config.exception_statuses[exception.class.name]
      end

      def status_code
        @status_code ||= Rack::Utils.status_code(status)
      end

      def notify?
        not config.non_notifying_exceptions.include?(name)
      end

      private
      attr_reader :notifier, :logger

      def listener_response
        if listener
          listener.respond_to do |f|
            f.html { listener.render template: config.html_template_path,
                                     layout: config.layout_name,
                                     status: status }

            f.json { listener.render json: { error_id: error_id },
                                     status: status }

            f.all { listener.render nothing: true,
                                    status: status }
          end
        end
      end

      def send_notifying_exceptions
        if notify?
          notifier.notify_exception(
            exception,
            env: listener.request.env,
            data: {
              error_id: error_id,
              :class => name,
              message: message,
              first_line_of_backtrace: exception.backtrace.first,
              cause: cause,
              dns_name: dns_name,
              extras: extras
            },
            sections: %w(data request session environment backtrace)
          )
        end
      end

      def config
        RescueFrom.configuration
      end
    end
  end
end
