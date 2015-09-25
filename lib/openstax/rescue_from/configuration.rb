require 'exception_notification'

module OpenStax
  module RescueFrom
    class Configuration

      attr_accessor :raise_exceptions, :notifier, :html_error_template_path,
        :html_error_template_layout_name, :app_name, :app_env, :contact_name,
        :email_prefix, :sender_address, :exception_recipients

      def initialize
        @raise_exceptions = ![false, 'false'].include?(ENV['RAISE_EXCEPTIONS'])

        @app_name = ENV['APP_NAME']
        @app_env = ENV['APP_ENV']
        @contact_name = ENV['EXCEPTION_CONTACT_NAME']

        @notifier = ExceptionNotifier

        @html_error_template_path = 'errors/any'
        @html_error_template_layout_name = 'application'

        @email_prefix = "[#{app_name}] (#{app_env}) "
        @sender_address = ENV['EXCEPTION_SENDER']
        @exception_recipients = ENV['EXCEPTION_RECIPIENTS']
      end
    end
  end
end
