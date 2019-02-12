require 'services/send_email_confirmation_token'

RSpec.describe SendEmailConfirmationToken do
  let(:service_args) {{
    email: email_address,
    message_sent: message_sent_handler,
    not_found: not_found_handler
  }}

  let(:email_address) { 'nobody@example.com' }

  callback_double(:message_sent_handler, :not_found_handler)

  let!(:user_repo) {
    class_double('User').tap do |r|
      r.as_stubbed_const
      allow(r).to receive(:find_by).and_return(user)
    end
  }

  let(:user) {
    instance_double('User',
                    update_attributes!: nil,
                    email: email_address,
                    confirmation_token: nil)
  }

  let!(:token_factory) {
    class_double('EmailConfirmationToken').tap do |f|
      f.as_stubbed_const
      allow(f).to receive(:new).and_return(confirmation_token)
    end
  }

  let(:confirmation_token) {
    instance_double('EmailConfirmationToken')
  }

  let!(:mailer) {
    class_double('UserMailer').tap do |f|
      f.as_stubbed_const
      allow(f).to receive(:with).and_return(f)
      allow(f).to receive(:email_confirmation).and_return(message)
    end
  }

  let(:message) {
    instance_double('ActionMailer::MessageDelivery', deliver_now: nil)
  }

  it 'looks for a user with the given email address' do
    subject.call
    expect(user_repo).to have_received(:find_by).with(email: email_address)
  end

  context 'when no user is found' do
    let(:user) { nil }

    it 'runs the not_found callback' do
      subject.call

      expect(not_found_handler).to have_been_called
    end

    it 'does not run the message_sent callback' do
      expect(message_sent_handler).not_to have_been_called
    end
  end

  context 'when the user is found' do
    it 'creates a new confirmation token' do
      subject.call
      expect(token_factory).to have_received(:new).with(email_address)
    end

    it 'updates the user with a new confirmation token' do
      subject.call
      expect(user).to(
        have_received(:update_attributes!)
        .with(confirmation_token: confirmation_token)
      )
    end

    it 'sends the confirmation email for the user' do
      subject.call
      expect(mailer).to have_received(:with).with(user: user).ordered
      expect(mailer).to have_received(:email_confirmation).ordered
      expect(message).to have_received(:deliver_now).ordered
    end

    it 'runs the message_sent callback' do
      subject.call
      expect(message).to have_received(:deliver_now).ordered
      expect(message_sent_handler).to have_been_called.ordered
    end

    it 'does not run the not_found callback' do
      subject.call
      expect(not_found_handler).not_to have_been_called
    end

    context 'when the user has an existing confirmation token' do
      before do
        allow(user).to receive(:confirmation_token).and_return('12345')
      end

      it 'does not change the confirmation token' do
        subject.call
        expect(user).not_to have_received(:update_attributes!)
      end
    end
  end
end
