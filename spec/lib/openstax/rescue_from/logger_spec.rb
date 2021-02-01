require 'rails_helper'
require 'openstax/rescue_from/exception_proxy'
require 'openstax/rescue_from/logger'

module OpenStax
  module RescueFrom
    RSpec.describe Logger do
      before do
        OpenStax::RescueFrom.configure do |c|
          c.raise_exceptions = false
        end
      end

      it 'recursively logs exceptions with causes' do
        begin
          raise ArgumentError
        rescue => cause
          begin
            raise StandardError
          rescue => exception
            expect(exception.cause).to eq cause

            logger = described_class.new(ExceptionProxy.new(exception))
            logger.logger.level = ::Logger::FATAL

            allow(described_class).to receive(:new) { logger }
            expect(logger).to receive(:record_system_error!).with(no_args).once.and_call_original
            expect(logger).to receive(:record_system_error_recursively!).twice.and_call_original
            expect(logger).to(
              receive(:record_system_error!).with("Exception cause").once.and_call_original
            )

            RescueFrom.perform_rescue(exception)
          end
        end
      end
    end
  end
end
