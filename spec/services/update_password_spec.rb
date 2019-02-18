require 'services/update_password'

RSpec.describe UpdatePassword do
  let(:service_args) {{
    user: user,
    new_password: new_password,
    success: success_handler
  }}

  let(:user) { instance_double('User', update_attributes!: nil) }

  let(:new_password) { 'my new password' }

  callback_double(:success_handler)

  service_double(:get_user, 'GetUser') { |user:, with_result:, **_|
    with_result.call(user)
  }

  it_requires_permission :change_password, on: :user

  it 'fetches the specified user' do
    subject.call
    expect(get_user).to(
      have_received_service_call(user: user, allow_update: true,
                                 with_result: duck_type(:call))
    )
  end

  it 'updates the user with the provided password' do
    subject.call
    expect(user)
      .to have_received(:update_attributes!).with(password: new_password)
  end

  it 'calls the success handler' do
    subject.call
    expect(success_handler).to have_been_called
  end
end
