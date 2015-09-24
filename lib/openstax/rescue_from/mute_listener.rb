module OpenStax
  module RescueFrom
    class MuteListener
      def before_openstax_exception_rescue(wrapped)
        RescueFrom.configuration.system_logger.warn(
          "MuteListener does nothing before rescuing " +
          "WrappedException#error_id #=> #{wrapped.error_id}"
        )
      end

      def after_openstax_exception_rescue(wrapped)
        RescueFrom.configuration.system_logger.warn(
          "MuteListener does nothing after rescuing " +
          "WrappedException#error_id #=> #{wrapped.error_id}"
        )
      end
    end
  end
end
