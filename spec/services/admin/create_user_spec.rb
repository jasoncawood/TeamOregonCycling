require 'services/admin/create_user'

RSpec.describe Admin::CreateUser do
  let(:service_args) {{
    email: email_address,
    first_name: first_name,
    last_name: last_name,
    role_ids: role_ids,
    success: success_callback,
    error: error_callback
  }}

  let(:email_address) { 'nobody@example.com' }
  let(:first_name) { 'No' }
  let(:last_name) { 'Body' }
  let(:role_ids) { %w[1 2 3] }

  callback_double(:success_callback, :error_callback)

  let!(:user_factory) { class_double('User', new: user).as_stubbed_const }
  let(:user) { instance_double('User') }

  let!(:password_factory) {
    class_double('RandomPassword', new: password).as_stubbed_const
  }
  let(:password) { 'D0EC784E-F79D-4FA7-8282-6D5847AC1129' }

  service_double(:user_validator, 'ValidateUser')

  it_requires_permission :manage_users

  it 'creates a random password' do
    subject.call
    expect(password_factory).to have_received(:new)
  end

  it 'builds a user with the specified attributes' do
    subject.call
    expect(user_factory).to(
      have_received(:new)
      .with(email: email_address,
            first_name: first_name,
            last_name: last_name,
            role_ids: role_ids,
            password: password)
    )
  end

  it 'validates the user object for admin creation' do
    subject.call
    expect(user_validator).to(
      have_received_service_call(
        user: user,
        purpose: :admin_create_user,
        valid: duck_type(:call),
        invalid: duck_type(:call)
      )
    )
  end

  context 'when the user is valid' do
    it 'adds the user to the repository'
    it 'sends the user welcome message'
    it 'calls the success message'
  end
end
