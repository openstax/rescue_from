module OpenStax
  module RescueFrom
    class MuteListener
      def openstax_exception_rescued(proxy, _)
        Rails.logger.warn("MuteListener does nothing after rescuing " +
                          "ExceptionProxy#error_id #=> #{proxy.error_id}")
      end

      def request
        OpenStruct.new(remote_ip: '0.0.0.0')
      end
    end
  end
end
