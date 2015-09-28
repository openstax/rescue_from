module OpenStax
  module RescueFrom
    class ExceptionOptions
      attr_accessor :notify, :status_code, :extras

      def initialize(options = {})
        options.stringify_keys!
        options = { 'notify' => true,
                    'status' => :internal_server_error,
                    'extras' => ->(exception) { {} } }.merge(options)

        @notify = options['notify']
        @status_code = options['status']
        @extras = options['extras']
      end

      def notify?
        @notify
      end
    end
  end
end
