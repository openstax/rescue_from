require 'rails_helper'

RSpec.describe ActiveJob do
  let(:examples) do
    ['SecurityTransgression', 'OAuth2::Error', 'ActiveRecord::RecordNotFound']
  end

  before do
    allow(SecureRandom).to receive(:random_number) { 123 }
  end

  examples.each do |ex|
    it "logs the #{ex} exception" do
      expect(Rails.logger).to receive(:error)

      allow_any_instance_of(ex.constantize).to receive(:message) { 'ex msg' }
      allow_any_instance_of(ex.constantize).to receive(:backtrace) { ['backtrace ln'] }
      allow_any_instance_of(OpenStax::RescueFrom::ExceptionProxy).to receive(:extras) {
        {}
      }

      begin
        TestJob.perform_later(ex)
      rescue
        expect(Rails.logger).to have_received(:error).with(
          "A background exception occurred: #{ex} [%06d123] <ex msg> {}\n\nbacktrace ln"
        )
      end
    end
  end

  it 'does not send emails for non-notifying exceptions' do
    ActionMailer::Base.deliveries.clear

    OpenStax::RescueFrom.non_notifying_exceptions.each do |ex|
      begin
        TestJob.perform_later(ex)
      rescue
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end

  it 'emails for other StandardErrors' do
    ActionMailer::Base.deliveries.clear

    begin
      TestJob.perform_later('StandardError')
    rescue
      expect(ActionMailer::Base.deliveries).not_to be_empty

      mail = ActionMailer::Base.deliveries.first

      expect(mail.from).to eq(['donotreply@dummyapp.com'])
      expect(mail.to).to eq(['notify@dummyapp.com'])
      expect(mail.subject).to eq(
        '[RescueFrom Dummy App] (DUM) (StandardError) "StandardError"'
      )
    end
  end
end
