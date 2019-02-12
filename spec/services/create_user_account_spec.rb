require 'services/create_user_account'

RSpec.describe CreateUserAccount do
  let(:service_args) {{
    account_details: account_details,
    success: success_handler,
    error: error_handler
  }}

  let(:account_details) {
    instance_double('UsersController::NewUserForm').tap do |o|
      allow(o).to receive(:to_h).and_return(email: email_address)
    end
  }

  let(:email_address) { 'nobody@example.com' }

  let!(:user_factory) {
    class_double('User').tap do |f|
      f.as_stubbed_const
      allow(f).to receive(:create).and_return(user)
    end
  }

  let(:user) {
    instance_double('User', valid?: true, email: email_address)
  }

  callback_double(:success_handler, :error_handler)

  service_double(:send_email_confirmation, 'SendEmailConfirmationToken')

  it 'creates the user with the supplied attributes' do
    subject.call
    expect(user_factory).to have_received(:create).with(email: email_address)
  end

  context 'when the user is not valid' do
    let(:errors) { instance_double('ActiveModel::Errors', 'user errors') }

    before do
      allow(user).to receive(:valid?).and_return(false)
      allow(user).to receive(:errors).and_return(errors)
    end

    it 'does not call the success handler' do
      subject.call
      expect(success_handler).not_to have_been_called
    end

    it 'calls the error handler with the validation errors' do
      subject.call
      expect(error_handler).to have_been_called_with(errors)
    end
  end

  context 'when the user is valid' do
    it 'does not call the error handler' do
      subject.call
      expect(error_handler).not_to have_been_called
    end

    it 'calls the success handler with the new user' do
      subject.call
      expect(success_handler).to have_been_called_with(user)
    end

    it 'sends an email confirmation message to the user' do
      subject.call
      expect(send_email_confirmation)
        .to have_received_service_call(email: user.email)
    end
  end
end
