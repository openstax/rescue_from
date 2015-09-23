require 'active_support/all'
require 'exception_notification'

require "openstax/rescue_from/configuration"
require "openstax/rescue_from/version"
require 'openstax/rescue_from/engine'

require "openstax/rescue_from/deploy_utils"
require 'openstax/rescue_from/logger'
require 'openstax/rescue_from/error'
require 'openstax/rescue_from/friendly_message'
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
      @message = FriendlyMessage.translate(wrapped_exception.status)
      @code = Rack::Utils.status_code(wrapped_exception.status)
      @error_id = wrapped_exception.error_id
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
