module OpenStax
  module RescueFrom
    class Engine < ::Rails::Engine
      initializer 'openstax.rescue_from.inflection' do
        ActiveSupport::Inflector.inflections do |inflect|
          inflect.acronym 'OpenStax'
        end
      end

      initializer "openstax.rescue_from.action_controller" do
        ActionController::Base.send :include, RescueFrom::Controller
      end

      middleware.use ExceptionNotification::Rack, email: {
        email_prefix: RescueFrom.configuration.email_prefix,
        sender_address: RescueFrom.configuration.sender_address,
        exception_recipients: RescueFrom.configuration.exception_recipients
      }
    end
  end
end
