require 'rails_helper'

RSpec.describe Admin::ListUsers do
  let(:service_args) {{
    with_result: result_handler
  }}

  let!(:context_user) { create(:user, last_name: 'User', first_name: 'Bob') }
  let(:result_handler) { instance_double('Proc', :result, call: nil) }

  let!(:user_a) { create(:user, last_name: 'Doe', first_name: 'John') }
  let!(:user_b) { create(:user, last_name: 'Adams', first_name: 'Frank') }
  let!(:user_c) { create(:user, last_name: 'Doe', first_name: 'Ann') }

  service_double(:authorizer, 'Authorize') { |authorized:, **_|
    authorized.call
  }

  it_requires_permission :manage_users

  it 'provides all of the users, sorted by last name then first name' do
    subject.call
    expect(result_handler).to have_received(:call).with(
      [user_b, user_c, user_a, context_user]
    )
  end

  it 'does not include discarded users' do
    user_b.discard
    subject.call
    expect(result_handler).to have_received(:call).with(
      [user_c, user_a, context_user]
    )
  end
end
