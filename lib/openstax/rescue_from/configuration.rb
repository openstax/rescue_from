module OpenStax
  module RescueFrom
    class Configuration

      attr_accessor :raise_exceptions, :raise_background_exceptions, :notify_exceptions,
        :notify_proc, :notify_background_exceptions, :notify_background_proc,
        :notify_rack_middleware, :notify_rack_middleware_options,
        :html_error_template_path, :html_error_template_layout_name, :app_name

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
        @contact_name = ENV['EXCEPTION_CONTACT_NAME']

        @notify_exceptions = true
        @notify_proc = ->(proxy, controller) {}
        @notify_background_exceptions = true
        @notify_background_proc = ->(proxy) {}

        @html_error_template_path = 'errors/any'
        @html_error_template_layout_name = 'application'
      end
    end
  end
end
