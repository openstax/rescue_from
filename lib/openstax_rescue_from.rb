require 'openstax/rescue_from/engine'
require 'openstax/rescue_from/wrapped_exception'

module OpenStax
  module RescueFrom
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def openstax_exception_rescue
        rescue_from Exception, with: :rescue_from_openstax_exception
      end
    end

    def rescue_from_openstax_exception(exception)
      wrapped_exception = WrappedException.new(exception: exception, listener: self)
      wrapped_exception.handle_exception!
    end

    class << self
      #   OpenStax::RescueFrom.configure do |config|
      #     config.<parameter name> = <parameter value>
      #     ...
      #   end
      def configure
        yield configuration
      end

      def configuration
        @configuration ||= Configuration.new
      end
    end
  end
end
