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
    end
  end
end
