require 'rails_helper'

RSpec.describe Admin::UpdateUser do

  let(:service_args) {{
    user: user,
    changes: changes,
    success: success_callback,
    error: error_callback
  }}

  let(:context_user) { create(:user) }
  let(:user) { create(:user) }
  let(:changes) {{
    first_name: "updated-#{user.first_name}",
    last_name: "updated-#{user.last_name}",
  }}
  callback_double(:success_callback, :error_callback)

  service_double(:authorizer, 'Authorize') { |**args|
    args.fetch(:authorized, -> {}).call
  }

  it_requires_permission :update, on: :user

  context 'when no role ids are present' do
    it 'does not require the manage_users permission' do
      subject.call
      expect(authorizer).not_to have_been_called_with(permission: :manage_users)
    end
  end

  context 'when role ids are present' do
    let!(:role) { create(:role) }
    before do
      changes[:role_ids] = [role.id]
    end

    it_requires_permission :manage_users
  end

  context 'when roles are present' do
    let!(:role) { create(:role) }
    before do
      changes[:roles] = [role]
    end

    it_requires_permission :manage_users
  end

  context 'when the changes are valid' do
    it 'calls the success callback with the updated user' do
      subject.call
      expect(success_callback).to have_been_called_with(user)
    end

    it 'updates the fields from the changes' do
      subject.call
      user.reload
      changes.each do |attr, value|
        expect(user.send(attr)).to eq value
      end
    end

    it 'does not call the error callback' do
      subject.call
      expect(error_callback).not_to have_received(:call)
    end
  end

  context 'when the changes are not valid' do
    let(:changes) {{
      first_name: ''
    }}

    it 'calls the error callback with the invalid user' do
      subject.call
      expect(error_callback).to have_been_called_with(satisfy { |v|
        expect(v).to eq user
        expect(v.errors.details[:first_name]).not_to be_empty
      })
    end

    it 'does not update the user' do
      subject.call
      current_state = User.find(user.id)
      expect(current_state.first_name).not_to eq changes[:first_name]
    end

    it 'does not call the success callback' do
      subject.call
      expect(success_callback).not_to have_received(:call)
    end
  end
end
