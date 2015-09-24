require 'exception_notification'

require "openstax/rescue_from/configuration"
require "openstax/rescue_from/version"
require 'openstax/rescue_from/engine'

require "openstax/rescue_from/controller"
require "openstax/rescue_from/deploy_utils"
require 'openstax/rescue_from/logger'
require 'openstax/rescue_from/error'
require 'openstax/rescue_from/wrapped_exception'

module OpenStax
  module RescueFrom
    class << self
      def configure
        yield configuration
      end

      def configuration
        @configuration ||= Configuration.new
      end
    end
  end
end
