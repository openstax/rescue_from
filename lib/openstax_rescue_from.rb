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
      respond_to do |type|
        type.html { render template: 'errors/any', layout: 'application', status: status }
        type.json { render json: error_json, status: status }
        type.all { render nothing: true, status: status }
      end
    end

    def error_json
      { error_id: "%06d#{SecureRandom.random_number(10**6)}" }
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
