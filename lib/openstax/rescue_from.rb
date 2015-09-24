require 'openstax/rescue_from/configuration'
require 'openstax/rescue_from/mute_listener'
require 'openstax/rescue_from/logger'
require 'openstax/rescue_from/error'
require 'openstax/rescue_from/exception_proxy'
require 'openstax/rescue_from/controller'

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
