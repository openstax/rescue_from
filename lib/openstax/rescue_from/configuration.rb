require 'exception_notification'

module OpenStax
  module RescueFrom
    class Configuration

      attr_accessor :raise_exceptions, :notifier, :html_error_template_path,
        :html_error_template_layout_name, :app_name, :app_env, :email_prefix,
        :sender_address, :exception_recipients

      def initialize
        @raise_exceptions = ENV['RAISE_EXCEPTIONS'] || false

        @app_name = ENV['APP_NAME'] || 'Tutor'
        @app_env = ENV['APP_ENV'] || 'DEV'

        @notifier = ExceptionNotifier

        @html_error_template_path = 'errors/any'
        @html_error_template_layout_name = 'application'

        @email_prefix = "[#{app_name}] (#{app_env}) "
        @sender_address = ENV['EXCEPTION_SENDER'] ||
                            %{"OpenStax Tutor" <noreply@openstax.org>}
        @exception_recipients = ENV['EXCEPTION_RECIPIENTS'] ||
                                   %w{tutor-notifications@openstax.org}
      end
    end
  end
end
