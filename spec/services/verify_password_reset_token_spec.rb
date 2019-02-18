require 'services/verify_password_reset_token'

RSpec.describe VerifyPasswordResetToken do
  let(:service_args) {{
    token: token,
    success: success_handler,
    invalid: invalid_handler,
  }}

  let(:token) { 'sometoken' }

  callback_double(:success_handler, :invalid_handler)

  let!(:user_repo) {
    class_double('User').tap do |r|
      r.as_stubbed_const
      allow(r).to receive(:find_by).and_return(user)
    end
  }

  let(:user) { nil }

  it 'looks for a user with an unexpired password reset token matching the input' do
    subject.call
    expect(user_repo).to(
      have_received(:find_by)
      .with('password_reset_token = :token AND ' \
            'password_reset_token_expires_at > NOW()',
            token: token)
    )
  end

  context 'when no such user is found' do
    it 'calls the invalid handler' do
      subject.call
      expect(invalid_handler).to have_been_called
    end

    it 'does not call the success handler' do
      subject.call
      expect(success_handler).not_to have_been_called
    end
  end

  context 'when a matching user is found' do
    let(:user) { instance_double('User', update_attributes!: nil) }

    it 'invalidates the password reset token' do
      subject.call
      expect(user).to(
        have_received(:update_attributes!)
        .with(password_reset_token: nil, password_reset_token_expires_at: nil)
      )
    end

    it 'calls the success callback with the user' do
      subject.call
      expect(success_handler).to have_been_called_with(user)
    end

    it 'does not call the invalid handler' do
      subject.call
      expect(invalid_handler).not_to have_been_called
    end
  end
end
