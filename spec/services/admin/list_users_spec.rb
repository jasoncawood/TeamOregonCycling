require 'rails_helper'

RSpec.describe Services::Admin::ListUsers do
  subject { described_class.new(**service_args) }

  let(:service_args) {{
    context: user,
    logger: logger,
    with_result: result_handler
  }}

  let!(:user) { create(:user, last_name: 'User', first_name: 'Bob') }
  let(:logger) { instance_double('Logger').as_null_object }
  let(:result_handler) { instance_double('Proc', :result, call: nil) }

  let!(:user_a) { create(:user, last_name: 'Doe', first_name: 'John') }
  let!(:user_b) { create(:user, last_name: 'Adams', first_name: 'Frank') }
  let!(:user_c) { create(:user, last_name: 'Doe', first_name: 'Ann') }

  it 'requires the :manage_users permission' do
    expect{subject.call}.to raise_error TheHelp::NotAuthorizedError
  end

  context 'when the context user has the :manage_users permission' do
    let(:role) { create(:role, permissions: [:manage_users]) }

    before do
      user.update_attributes!(roles: [role])
    end

    it 'provides all of the users, sorted by last name then first name' do
      subject.call
      expect(result_handler).to have_received(:call).with(
        [user_b, user_c, user_a, user]
      )
    end
  end
end
