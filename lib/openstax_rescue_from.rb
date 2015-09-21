require 'openstax/rescue_from/engine'
require 'openstax/rescue_from/exceptions'

module OpenStax
  module RescueFrom
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def openstax_rescue
        rescue_from Exception, with: :rescue_from_openstax_exception
      end
    end

    def rescue_from_openstax_exception(exception)
      status = Exceptions::STATUS_MAP[exception.class.name]
      render template: 'errors/any', layout: 'application', status: status
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
