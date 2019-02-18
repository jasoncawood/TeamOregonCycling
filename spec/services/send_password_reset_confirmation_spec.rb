require 'services/send_password_reset_confirmation'

RSpec.describe SendPasswordResetConfirmation do
  let(:service_args) {{
    email: email,
    success: success_handler,
    not_found: not_found_handler,
    clock: system_clock
  }}

  let(:email) { 'nobody@example.com' }

  callback_double(:success_handler, :not_found_handler)

  let(:system_clock) {
    class_double('Time').tap do |c|
      allow(c).to receive(:now).and_return(current_time)
    end
  }

  let(:current_time) { Time.new(2018, 2, 16, 10, 21, 32) }

  let!(:user_repo) {
    class_double('User').tap do |r|
      r.as_stubbed_const
      allow(r).to receive(:find_by).and_return(user)
    end
  }

  let(:user) { nil }

  let!(:mailer) {
    class_double('UserMailer').tap do |m|
      m.as_stubbed_const
      allow(m).to receive(:send_password_reset_confirmation)
    end
  }

  let!(:token_factory) {
    class_double('PasswordResetToken').tap do |f|
      f.as_stubbed_const
      allow(f).to receive(:new).and_return(token)
    end
  }

  let(:token) { instance_double('PasswordResetToken', to_s: 'sometoken') }

  it 'looks for a user matching the supplied email address' do
    subject.call
    expect(user_repo).to have_received(:find_by).with(email: email)
  end

  context 'when no matching user is found' do
    it 'does not deliver a password reset confirmation email' do
      subject.call
      expect(mailer).not_to have_received(:send_password_reset_confirmation)
    end

    it 'calls the not_found handler with the submitted email address' do
      subject.call
      expect(not_found_handler).to have_been_called_with(email)
    end

    it 'does not call the success handler' do
      subject.call
      expect(success_handler).not_to have_been_called
    end
  end

  context 'when a matching user is found' do
    let(:user) {
      instance_double('User', update_attributes!: nil)
    }

    it 'generates a new password reset token' do
      subject.call
      expect(token_factory).to have_received(:new).with(email: email)
    end

    it 'updates the user with the reset token and token expiration' do
      subject.call
      expect(user).to(
        have_received(:update_attributes!)
        .with(password_reset_token: token,
              password_reset_token_expires_at: current_time + (24 * 60 * 60))
      )
    end

    it 'sends the user a password reset confirmation email containing the token' do
      subject.call
      expect(mailer)
        .to have_received(:send_password_reset_confirmation).with(user: user)
    end

    it 'calls the success handler with the submitted email address' do
      subject.call
      expect(success_handler).to have_been_called_with(email)
    end

    it 'does not call the not_found handler' do
      subject.call
      expect(not_found_handler).not_to have_been_called
    end
  end
end
