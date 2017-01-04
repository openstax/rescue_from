require 'rails_helper'
require './spec/support/exceptions_list'
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
        logger = nil

        begin
          raise ArgumentError
        rescue => cause
          begin
            raise StandardError
          rescue => e
            logger = described_class.new(ExceptionProxy.new(e))

            allow(described_class).to receive(:new) { logger }
            allow(logger).to receive(:record_system_error!).and_call_original

            RescueFrom.perform_rescue(e)

            expect(logger).to have_received(:record_system_error!).with(no_args).once

            if RUBY_VERSION.first != '1'
              expect(logger).to have_received(:record_system_error!).with("Exception cause").once
            end
          end
        end
      end
    end
  end
end
