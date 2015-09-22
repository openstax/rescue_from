require 'rails_helper'
require './spec/support/exceptions_list'
require 'openstax/rescue_from/exception_wrapper'
require 'openstax/rescue_from/logger'

module OpenStax
  module RescueFrom
    RSpec.describe Logger do
      it 'recursively logs exceptions with causes' do
        cause = double(:caused, :blank? => false).as_null_object
        exception = double(:exception, cause: cause).as_null_object

        wrapper = ExceptionWrapper.new(exception: exception, listener: nil, logger: nil)

        logger = described_class.new(exception: wrapper)

        allow(logger).to receive(:record_rails_error!).and_call_original

        logger.record_rails_error!

        expect(logger).to have_received(:record_rails_error!).twice
      end
    end
  end
end
