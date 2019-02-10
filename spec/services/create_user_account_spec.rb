require 'services/create_user_account'

RSpec.describe CreateUserAccount do
  let(:service_args) {{
    account_details: account_details,
    success: success_handler,
    error: error_handler
  }}

  let(:account_details) {
    instance_double('UsersController::NewUserForm').tap do |o|
      allow(o).to receive(:valid?).and_return(true)
    end
  }

  let!(:user_factory) {
    class_double('User').tap do |f|
      f.as_stubbed_const
    end
  }

  callback_double(:success_handler, :error_handler)

  xit 'validates the incoming account details' do
    subject.call
    expect(account_details).to have_received(:valid?)
  end
end
