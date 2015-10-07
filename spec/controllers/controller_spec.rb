require 'rails_helper'
require './spec/support/test_controller'

module Test
  RSpec.describe TestController do
    let(:examples) { ['SecurityTransgression',
                      'OAuth2::Error',
                      'ActiveRecord::RecordNotFound'] }

    before do
      allow(SecureRandom).to receive(:random_number) { 123 }
    end

    context 'configured to raise exceptions' do
      before { OpenStax::RescueFrom.configure { |c| c.raise_exceptions = true } }

      it 'raises the exceptions' do
        examples.each do |ex|
          expect {
            get :bad_action, exception: ex
          }.to raise_error(ex.constantize)
        end
      end
    end

    examples.each do |ex|
      it "logs the #{ex} exception" do
        allow(Rails.logger).to receive(:error)

        allow_any_instance_of(ex.constantize).to receive(:message) { 'ex msg' }
        allow_any_instance_of(ex.constantize).to receive(:backtrace) { ['backtrace ln'] }
        allow_any_instance_of(OpenStax::RescueFrom::ExceptionProxy).to receive(:extras) {
          {}
        }

        get :bad_action, exception: ex

        expect(Rails.logger).to have_received(:error).with(
          "An exception occurred: #{ex} [000123] <ex msg> {}\n\nbacktrace ln"
        )
      end
    end

    it 'intercepts non notifying exceptions' do
      OpenStax::RescueFrom.non_notifying_exceptions.each do |ex|
        get :bad_action, exception: ex

        expected_status = OpenStax::RescueFrom.status(ex)

        expect(response).to render_template('errors/any')
        expect(response).to have_http_status(expected_status),
          "expected #{expected_status}, got #{response.status} - for #{ex}"
      end
    end

    it 'intercepts these non notifying exceptions for json requests' do
      OpenStax::RescueFrom.non_notifying_exceptions.each do |ex|
        get :bad_action, exception: ex, format: :json

        expected_status = OpenStax::RescueFrom.status(ex)

        expect(JSON.parse(response.body)).to eq({ 'error_id' => nil })
        expect(response).to have_http_status(expected_status),
          "expected #{expected_status}, got #{response.status} - for #{ex}"
      end
    end

    it 'intercepts non notifying exception for other formats with just the status' do
      formats = [:xsl, :php, :doc, :pdf, :csv, :xml]

      OpenStax::RescueFrom.non_notifying_exceptions.each do |ex|
        get :bad_action, exception: ex, format: formats.sample

        expected_status = OpenStax::RescueFrom.status(ex)

        expect(response.body).to be_blank
        expect(response).to have_http_status(expected_status),
          "expected #{expected_status}, got #{response.status} - for #{ex}"
      end
    end

    it 'uses 500 for unknown exceptions in the status map' do
      get :bad_action, exception: 'OAuth2::Error'
      expect(response).to have_http_status(500)
      expect(response).to render_template('errors/any')
    end

    it 'does not send emails for non-notifying exceptions' do
      ActionMailer::Base.deliveries.clear

      OpenStax::RescueFrom.non_notifying_exceptions.each do |ex|
        get :bad_action, exception: ex
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    it 'emails for other exceptions' do
      ActionMailer::Base.deliveries.clear

      get :bad_action, exception: 'ArgumentError'

      expect(ActionMailer::Base.deliveries).not_to be_empty

      mail = ActionMailer::Base.deliveries.first

      expect(mail.from).to eq(['donotreply@dummyapp.com'])
      expect(mail.to).to eq(['notify@dummyapp.com'])
      expect(mail.subject).to eq('[RescueFrom Dummy App] (DUM) # (ArgumentError) "ArgumentError"')
    end

    it 'sets message and code instance variables for html response' do
      get :bad_action, exception: 'ArgumentError'

      expect(assigns[:code]).to eq(500)
      expect(assigns[:error_id]).to eq("000123")
      expect(assigns[:message]).to eq(
        "Sorry, RescueFrom Dummy App had some unexpected trouble with your request."
      )
    end
  end
end
