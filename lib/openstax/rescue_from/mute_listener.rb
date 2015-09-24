module OpenStax
  module RescueFrom
    class MuteListener
      def before_openstax_exception_rescue(proxy)
        RescueFrom.configuration.logger.warn(
          "MuteListener does nothing before rescuing " +
          "ExceptionProxy#error_id #=> #{proxy.error_id}"
        )
      end

      def after_openstax_exception_rescue(proxy)
        RescueFrom.configuration.logger.warn(
          "MuteListener does nothing after rescuing " +
          "ExceptionProxy#error_id #=> #{proxy.error_id}"
        )
      end
    end
  end
end
