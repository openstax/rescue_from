require 'rails_helper'

RSpec.describe OpenStax::RescueFrom do
  let(:exception) { StandardError.new }

  it 'pre-registers a handful of exceptions' do
    exceptions = OpenStax::RescueFrom.registered_exceptions

    active_record_not_found = exceptions['ActiveRecord::RecordNotFound']
    expect(active_record_not_found).not_to be_notify
    expect(active_record_not_found.status_code).to be(:not_found)
    expect(active_record_not_found.extras.call(nil)).to eq({})

    action_controller_routing = exceptions['ActionController::RoutingError']
    expect(action_controller_routing).not_to be_notify
    expect(action_controller_routing.status_code).to be(:not_found)
    expect(action_controller_routing.extras.call(nil)).to eq({})

    controller_invalid_token = exceptions['ActionController::InvalidAuthenticityToken']
    expect(controller_invalid_token).not_to be_notify
    expect(controller_invalid_token.status_code).to be(:unprocessable_entity)
    expect(controller_invalid_token.extras.call(nil)).to eq({})

    controller_action_not_found = exceptions['AbstractController::ActionNotFound']
    expect(controller_action_not_found).not_to be_notify
    expect(controller_action_not_found.status_code).to be(:not_found)
    expect(controller_action_not_found.extras.call(nil)).to eq({})

    missing_template = exceptions['ActionView::MissingTemplate']
    expect(missing_template).not_to be_notify
    expect(missing_template.status_code).to be(:bad_request)
    expect(missing_template.extras.call(nil)).to eq({})

    security_transgression = exceptions['SecurityTransgression']
    expect(security_transgression).not_to be_notify
    expect(security_transgression.status_code).to be(:forbidden)
    expect(security_transgression.extras.call(nil)).to eq({})

    oauth_error = exceptions['OAuth2::Error']
    response = double(:response, headers: 'headers', status: 500, body: 'bad times')
    exception = double(:exception, response: response)

    expect(oauth_error).to be_notify
    expect(oauth_error.status_code).to be(:internal_server_error)
    expect(oauth_error.extras.call(exception)).to eq({ headers: 'headers',
                                                       status: 500,
                                                       body: 'bad times' })

    apipie_param_missing = exceptions['Apipie::ParamMissing']
    expect(apipie_param_missing).not_to be_notify
    expect(apipie_param_missing.status_code).to be(:unprocessable_entity)
    expect(apipie_param_missing.extras.call(nil)).to eq({})

    unknown_http_method = exceptions['ActionController::UnknownHttpMethod']
    expect(unknown_http_method).not_to be_notify
    expect(unknown_http_method.status_code).to be(:bad_request)
    expect(unknown_http_method.extras.call(nil)).to eq({})

    parameter_missing = exceptions['ActionController::ParameterMissing']
    expect(parameter_missing).not_to be_notify
    expect(parameter_missing.status_code).to be(:bad_request)
    expect(parameter_missing.extras.call(nil)).to eq({})
  end

  context 'background (default)' do
    it 'can rescue from specific blocks of code' do
      expect(OpenStax::RescueFrom).to receive(:perform_background_rescue).with(exception)
      OpenStax::RescueFrom.this { raise exception }
    end

    context '#log_background_system_error' do
      it 'logs notifying exceptions' do
        expect(OpenStax::RescueFrom::Logger).to receive(:new).and_call_original
        expect_any_instance_of(OpenStax::RescueFrom::Logger).to(
          receive(:record_system_error!).with('A background job exception occurred')
        )

        proxy = OpenStax::RescueFrom::ExceptionProxy.new(StandardError.new 'test')
        described_class.send :log_background_system_error, proxy
      end

      it 'does not log non-notifying exceptions' do
        OpenStax::RescueFrom.register_exception ActiveRecord::RecordNotFound, notify: false

        expect(OpenStax::RescueFrom::Logger).not_to receive(:new)

        proxy = OpenStax::RescueFrom::ExceptionProxy.new(ActiveRecord::RecordNotFound.new 'test')
        described_class.send :log_background_system_error, proxy
      end
    end

    context '#do_not_reraise' do
      it 'turns off reraising' do
        original = OpenStax::RescueFrom.configuration.raise_background_exceptions
        OpenStax::RescueFrom.configuration.raise_background_exceptions = true

        begin
          expect do
            OpenStax::RescueFrom.do_not_reraise do
              OpenStax::RescueFrom.this { raise exception }
            end
          end.not_to raise_error
        ensure
          OpenStax::RescueFrom.configuration.raise_background_exceptions = original
        end
      end
    end
  end

  context 'foreground' do
    let(:background) { false }

    it 'can rescue from specific blocks of code in foreground mode' do
      expect(OpenStax::RescueFrom).to receive(:perform_rescue).with(exception)
      OpenStax::RescueFrom.this(background) { raise exception }
    end

    context '#log_system_error' do
      it 'logs notifying exceptions' do
        OpenStax::RescueFrom.register_exception StandardError

        expect(OpenStax::RescueFrom::Logger).to receive(:new).and_call_original
        expect_any_instance_of(OpenStax::RescueFrom::Logger).to receive(:record_system_error!)

        proxy = OpenStax::RescueFrom::ExceptionProxy.new(StandardError.new 'test')
        described_class.send :log_system_error, proxy
      end

      it 'does not log non-notifying exceptions' do
        OpenStax::RescueFrom.register_exception ActiveRecord::RecordNotFound, notify: false

        expect(OpenStax::RescueFrom::Logger).not_to receive(:new)

        proxy = OpenStax::RescueFrom::ExceptionProxy.new(ActiveRecord::RecordNotFound.new 'test', notify: false)
        described_class.send :log_system_error, proxy
      end
    end

    context '#do_not_reraise' do
      it 'turns off reraising' do
        original = OpenStax::RescueFrom.configuration.raise_exceptions
        OpenStax::RescueFrom.configuration.raise_exceptions = true

        begin
          expect do
            OpenStax::RescueFrom.do_not_reraise do
              OpenStax::RescueFrom.this(background) { raise exception }
            end
          end.not_to raise_error
        ensure
          OpenStax::RescueFrom.configuration.raise_exceptions = original
        end
      end
    end
  end
end
