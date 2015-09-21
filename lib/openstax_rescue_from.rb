require 'active_support/all'

ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'OpenStax'
end

require "openstax/rescue_from/configuration"
require "openstax/rescue_from/version"

module OpenStax
  module RescueFrom

      class << self

      ###########################################################################
      #
      # Configuration machinery.
      #
      # To configure OpenStax RescueFrom, put the following code in your
      # application's initialization logic
      # (eg. in the config/initializers in a Rails app)
      #
      #   OpenStax::RescueFrom.configure do |config|
      #     config.<parameter name> = <parameter value>
      #     ...
      #   end
      #

      def configure
        yield configuration
      end

      def configuration
        @configuration ||= Configuration.new
      end

    end
  end
end
