require 'exception_notification'

module OpenStax
  module RescueFrom
    class Configuration

      attr_accessor :raise_exceptions, :raise_background_exceptions, :notifier,
        :html_error_template_path, :html_error_template_layout_name, :app_name,
        :app_env, :email_prefix, :sender_address, :exception_recipients

      attr_writer :contact_name

      def contact_name
        @contact_name || "us"
      end

      def initialize
        @raise_exceptions = ![false, 'false'].include?(ENV['RAISE_EXCEPTIONS'])
        @raise_background_exceptions = ![false, 'false'].include?(
          ENV['RAISE_BACKGROUND_EXCEPTIONS']
        )

        @app_name = ENV['APP_NAME']
        @app_env = ENV['APP_ENV']
        @contact_name = ENV['EXCEPTION_CONTACT_NAME']

        @notifier = ExceptionNotifier

        @html_error_template_path = 'errors/any'
        @html_error_template_layout_name = 'application'

        @sender_address = ENV['EXCEPTION_SENDER']
        @exception_recipients = ENV['EXCEPTION_RECIPIENTS']
      end

      def email_prefix
        return(@email_prefix) if defined?(@email_prefix) && !@email_prefix.blank?

        name = app_name.blank? ? nil : "[#{app_name}]"
        env = app_env.blank? ? nil : "(#{app_env}) "

        @email_prefix = [name, env].compact.join(' ')
      end
    end
  end
end
