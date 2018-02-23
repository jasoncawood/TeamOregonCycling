require 'rails_helper'

RSpec.describe Admin::DeleteMembershipType do
  let(:service_args) {{
    membership_type: membership_type_to_delete,
    success: success
  }}

  let(:context_user) { create(:user) }
  let(:membership_type_to_delete) { create(:membership_type) }
  let(:success) { instance_double('Proc', 'success', call: nil) }

  service_double(:authorizer, 'Authorize') { |authorized:, **_|
    authorized.call
  }

  it_requires_permission :manage_users

  shared_examples_for :it_deletes_the_membership_type do
    it 'calls the success callback with the membership_type that was ' \
       'destroyed' do
      subject.call
      expect(success).to have_received(:call).with(membership_type_to_delete)
    end

    it 'discards the specified membership_type' do
      subject.call
      expect(MembershipType.kept.where(id: membership_type_to_delete.id).count)
        .to eq 0
    end

    it 'does not fully delete the specified membership_type' do
      subject.call
      expect(
        MembershipType.discarded.where(id: membership_type_to_delete.id).count
      ).to eq 1
    end
  end

  context 'when the membership_type to delete is passed as a MembershipType ' \
          'object' do
    it_behaves_like :it_deletes_the_membership_type
  end

  context 'when the membership_type to delete is passed as an id' do
    before do
      service_args[:membership_type] = membership_type_to_delete.id
    end

    it_behaves_like :it_deletes_the_membership_type
  end
end
