require 'rails_helper'
require './spec/support/exceptions_list'
require './spec/support/test_controller'

module Test
  RSpec.describe TestController do
    before do
      allow(SecureRandom).to receive(:random_number) { 123 }

      OpenStax::RescueFrom.configure do |c|
        c.raise_exceptions = false # default
      end

      OpenStax::RescueFrom.register_exception(SecurityTransgression,
                                              notify: false,
                                              status: :forbidden)

      OpenStax::RescueFrom.register_exception(ActiveRecord::RecordNotFound,
                                              notify: false,
                                              status: :not_found)

      OpenStax::RescueFrom.register_exception(OAuth2::Error,
                                              notify: true,
                                              extras: ->(exception) { 'found extras' })

      OpenStax::RescueFrom.translate_status_codes({
        forbidden: "You are not allowed to access this.",
        :not_found => "We couldn't find what you asked for.",
        internal_server_error: "Sorry, #{OpenStax::RescueFrom.configuration.app_name} had some unexpected trouble with your request."
      })
    end

    context 'configured to raise exceptions' do
      before do
        OpenStax::RescueFrom.configure do |c|
          c.raise_exceptions = true
        end
      end

      it 'raises the exceptions' do
        OpenStax::RescueFrom.registered_exceptions.each do |ex|
          expect {
            get :bad_action, exception: ex
          }.to raise_error(ex.constantize)
        end
      end
    end

    OpenStax::RescueFrom.registered_exceptions.each do |ex|
      it "logs the #{ex} exception" do
        allow(Rails.logger).to receive(:error)

        allow_any_instance_of(ex.constantize).to receive(:message) { 'ex msg' }
        allow_any_instance_of(ex.constantize).to receive(:backtrace) { ['backtrace ln'] }

        get :bad_action, exception: ex

        expect(Rails.logger).to have_received(:error).with(
          "An exception occurred: #{ex} [%06d123] <ex msg> found extras\n\nbacktrace ln"
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

        expect(JSON.parse(response.body)).to eq({ 'error_id' => '%06d123' })
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
    end

    it 'sets message and code instance variables for html response' do
      get :bad_action, exception: 'ArgumentError'

      expect(assigns[:code]).to eq(500)
      expect(assigns[:error_id]).to eq("%06d123")
      expect(assigns[:message]).to eq(
        "Sorry, Tutor had some unexpected trouble with your request."
      ) # 'Tutor' is configurable!
    end
  end
end
