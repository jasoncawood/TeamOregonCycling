require 'rails_helper'

RSpec.describe Authorize do
  subject { described_class.new(**service_args) }

  let(:service_args) {{
    context: user,
    logger: logger,
    permission: permission,
    authorized: authorized,
    not_authorized: not_authorized
  }}

  let(:user) { create(:user) }
  let(:logger) { instance_double('Logger').as_null_object }
  let(:permission) { :manage_users }
  let(:authorized) { instance_double('Proc', :authorized, call: nil) }
  let(:not_authorized) { instance_double('Proc', :not_authorized, call: nil) }

  shared_examples_for :it_is_not_authorized do
    it 'calls the not_authorized callback' do
      subject.call
      expect(not_authorized).to have_received(:call)
    end

    it 'does not call the authorized callback' do
      subject.call
      expect(authorized).not_to have_received(:call)
    end
  end

  shared_examples_for :it_is_authorized do
    it 'does not call the not_authorized callback' do
      subject.call
      expect(not_authorized).not_to have_received(:call)
    end

    it 'calls the authorized callback' do
      subject.call
      expect(authorized).to have_received(:call)
    end
  end

  context 'when the user has no roles assigned' do
    it_behaves_like :it_is_not_authorized
  end

  context 'when the user has one role assigned' do
    let(:role) { create(:role) }

    before do
      user.update_attributes!(roles: [role])
    end

    context 'when the assigned role does not have the permission' do
      it_behaves_like :it_is_not_authorized
    end

    context 'when the assigned role has the requested permission' do
      before do
        role.update_attributes!(permissions: [permission])
      end

      it_behaves_like :it_is_authorized
    end
  end

  context 'when the user has multiple roles assigned' do
    let(:role_1) { create(:role) }
    let(:role_2) { create(:role) }

    before do
      user.update_attributes!(roles: [role_1, role_2])
    end

    context 'when no roles have the permission' do
      it_behaves_like :it_is_not_authorized
    end

    context 'when the first role has the permission' do
      before do
        role_1.update_attributes!(permissions: [permission])
      end

      it_behaves_like :it_is_authorized
    end

    context 'when the last role has the permission' do
      before do
        role_2.update_attributes!(permissions: [permission])
      end

      it_behaves_like :it_is_authorized
    end
  end
end
