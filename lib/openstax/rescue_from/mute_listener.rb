module OpenStax
  module RescueFrom
    class MuteListener
      def openstax_exception_rescue_callback(wrapped)
        RescueFrom.configuration.system_logger.warn(
          "MuteListener#openstax_exception_rescue_callback does " +
          "nothing for WrappedException#error_id #=> #{wrapped.error_id}"
        )
      end
    end
  end
end
