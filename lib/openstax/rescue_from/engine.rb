require 'openstax/rescue_from/default_exceptions'

module OpenStax
  module RescueFrom
    class Engine < ::Rails::Engine
      initializer 'openstax.rescue_from.inflection' do
        ActiveSupport::Inflector.inflections do |inflect|
          inflect.acronym 'OpenStax'
        end
      end

      initializer "openstax.rescue_from.use_exception_notification_middleware" do
        Rails.application.config.middleware.use ExceptionNotification::Rack, email: {
          email_prefix: RescueFrom.configuration.email_prefix,
          sender_address: RescueFrom.configuration.sender_address,
          exception_recipients: RescueFrom.configuration.exception_recipients
        }
      end

      initializer "openstax.rescue_from.pre_register_exceptions" do
        OpenStax::RescueFrom::DefaultExceptions.pre_register!
      end
    end
  end
end
