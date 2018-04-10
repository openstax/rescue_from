require 'openstax/rescue_from/default_exceptions'

module OpenStax
  module RescueFrom
    class Engine < ::Rails::Engine
      initializer 'openstax.rescue_from.inflection' do
        ActiveSupport::Inflector.inflections do |inflect|
          inflect.acronym 'OpenStax'
        end
      end

      initializer "openstax.rescue_from.use_rack_middleware" do
        middleware = OpenStax::RescueFrom.configuration.notify_rack_middleware
        next if middleware.blank?

        options = OpenStax::RescueFrom.configuration.notify_rack_middleware_options
        if options.nil?
          Rails.application.config.middleware.insert_before 0, middleware
        else
          Rails.application.config.middleware.insert_before 0, middleware, options
        end
      end

      initializer "openstax.rescue_from.pre_register_exceptions" do
        OpenStax::RescueFrom::DefaultExceptions.pre_register!
      end
    end
  end
end
