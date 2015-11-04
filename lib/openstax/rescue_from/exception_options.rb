module OpenStax
  module RescueFrom
    class ExceptionOptions
      attr_accessor :notify, :status_code, :message, :extras

      def initialize(options = {})
        options.stringify_keys!
        options = { 'notify' => true,
                    'status' => :internal_server_error,
                    'message' => nil,
                    'extras' => ->(exception) { {} } }.merge(options)

        @notify = options['notify']
        @status_code = options['status']
        @message = options['message']
        @extras = options['extras']
      end

      def notify?
        @notify
      end
    end
  end
end
