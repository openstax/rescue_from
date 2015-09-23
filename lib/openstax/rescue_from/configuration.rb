module OpenStax
  module RescueFrom
    class Configuration

      attr_accessor :raise_exceptions, :system_logger, :notifier,
        :html_template_path, :layout_name

      def initialize
        @raise_exceptions = false
        @system_logger = Rails.logger
        @notifier = ExceptionNotifier
        @html_template_path = 'errors/any'
        @layout_name = 'application'
      end
    end
  end
end
