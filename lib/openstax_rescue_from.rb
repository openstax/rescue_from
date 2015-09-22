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
      log_rails_error(exception)

      if Rails.application.config.consider_all_requests_local
        raise exception
      else
        status = Exceptions::STATUS_MAP[exception.class.name]
        respond_to do |f|
          f.html { render template: 'errors/any', layout: 'application', status: status }
          f.json { render json: error_json, status: status }
          f.all { render nothing: true, status: status }
        end
      end
    end

    def log_rails_error(exception)
      name = exception.class.name
      message = exception.message
      extras = if extras_proc = Exceptions::EXTRAS_MAP[exception.class.name]
                 extras_proc.call(exception)
               end

      if exception.cause.blank?
        header = 'An exception occurred'
        backtrace = exception.backtrace.join("\n")

        Rails.logger.error("#{header}: #{name} [#{generate_error_id}] <#{message}> " +
                           "#{extras}\n\n#{backtrace}")
      else
        header = 'Exception cause'
        backtrace = exception.backtrace.first

        Rails.logger.error("#{header}: #{name} [#{generate_error_id}] <#{message}> " +
                           "#{extras}\n\n#{backtrace}")

        log_rails_error(exception.cause)
      end
    end

    def error_json
      { error_id: generate_error_id }
    end

    def generate_error_id
      "%06d#{SecureRandom.random_number(10**6)}"
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
