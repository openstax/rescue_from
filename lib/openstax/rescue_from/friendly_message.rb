module OpenStax
  module RescueFrom
    class FriendlyMessage
      def self.translate(status)
        case status
        when :forbidden
          "You are not allowed to access this."
        when :not_found
          "We couldn't find what you asked for."
        when :unprocessable_entity
          "We didn't understand what you asked for."
        when :internal_server_error
          "Sorry, #{config.application_name} had some unexpected trouble with your request."
        end
      end

      def self.config
        OpenStax::RescueFrom.configuration
      end
    end
  end
end
