require 'rails_helper'

RSpec.describe Admin::UpdateUser do
  subject { described_class.new(**service_args) }

  let(:service_args) {{
    context: context_user,
    logger: logger,
    user: user,
    changes: changes,
    success: success_callback,
    error: error_callback
  }}

  let(:context_user) { create(:user) }
  let(:logger) { instance_double('Logger').as_null_object }
  let(:user) { create(:user) }
  let(:changes) {{
    first_name: "updated-#{user.first_name}",
    last_name: "updated-#{user.last_name}",
  }}
  let(:success_callback) { instance_double('Proc', :success, call: nil) }
  let(:error_callback) { instance_double('Proc', :error, call: nil) }
  let(:context_user_has_manager_role) { false }
  let(:role_a) { create(:role) }
  let(:role_b) { create(:role) }

  let!(:authorizer) {
    class_double('Authorize').tap do |s|
      s.as_stubbed_const
      allow(s).to receive(:call) { |permission:, authorized:, not_authorized:, **_|
        if permission == :update || context_user_has_manager_role
          authorized.call
        else
          not_authorized.call
        end
      }
    end
  }

  it 'requires the :update permission on the target user' do
    subject.call
    expect(authorizer).to have_received(:call).with(
      context: context_user,
      logger: logger,
      permission: :update,
      on: user,
      authorized: duck_type(:call),
      not_authorized: duck_type(:call)
    )
  end

  context 'when the changes are valid' do
    it 'calls the success callback with the updated user' do
      subject.call
      expect(success_callback).to have_received(:call).with(user)
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
      expect(error_callback).to have_received(:call).with(satisfy { |v|
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

  shared_examples_for :it_allows_only_user_managers_to_update_roles do
    before do
      user.update_attributes!(roles: [role_a])
    end

    context 'when the context user does not have the manage_users permission' do
      let(:context_user_has_manager_role) { false }

      it 'does not allow the roles to be modified' do
        subject.call
        current_state = User.find(user.id)
        expect(current_state.roles).to eq [role_a]
      end

      it 'calls the error callback with an invalid user' do
        subject.call
        expect(error_callback).to have_received(:call).with(satisfy { |v|
          expect(v).to eq user
          expect(v.errors.details[:roles]).to eq([{error: :not_authorized}])
        })
      end

      it 'does not call the success callback' do
        subject.call
        expect(success_callback).not_to have_received(:call)
      end
    end

    context 'when the context user does have the manage_users permission' do
      let(:context_user_has_manager_role) { true }

      it 'modifies the roles for the user' do
        subject.call
        current_state = User.find(user.id)
        expect(current_state.roles).to eq [role_b]
      end

      it 'calls the success callback with the updated user' do
        subject.call
        expect(success_callback).to have_received(:call).with(user)
      end

      it 'does not call the error_callback' do
        subject.call
        expect(error_callback).not_to have_received(:call)
      end
    end
  end

  context 'when role_ids are present in the changes' do
    before do
      changes[:role_ids] = [role_b.id]
    end

    it_behaves_like :it_allows_only_user_managers_to_update_roles
  end

  context 'when roles are present in the changes' do
    before do
      changes[:roles] = [role_b]
    end

    it_behaves_like :it_allows_only_user_managers_to_update_roles
  end
end
