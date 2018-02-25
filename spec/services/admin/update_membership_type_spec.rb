require 'rails_helper'

RSpec.describe Admin::UpdateMembershipType do
  let(:service_args) {{
    membership_type: membership_type_id,
    data: data,
    success: success_handler,
    error: error_handler
  }}

  let(:context_user) { instance_double('User') }
  let(:membership_type_id) { membership_type.id }
  let(:membership_type) { create(:membership_type, name: 'A', price: 10.95) }

  let(:data) {{
    name: 'B',
    price: 7.50
  }}

  callback_double(:success_handler, :error_handler)

  service_double(:authorizer, 'Authorize') { |authorized:, **_|
    authorized.call
  }

  it_requires_permission :manage_users

  context 'when the changes are valid' do
    it 'saves the changes to the MembershipType record' do
      subject.call
      membership_type.reload
      expect(membership_type.name).to eq data[:name]
    end

    it 'calls the success handler with the updated membership type' do
      subject.call
      expect(success_handler).to have_been_called_with(membership_type)
    end

    it 'does not call the error callback' do
      subject.call
      expect(error_handler).not_to have_received(:call)
    end

    context 'when memberships of the type exist' do
      let!(:membership) { create(:membership, membership_type: membership_type) }

      it 'does not change the record of the price paid for the membership' do
        original_price = membership.amount_paid
        subject.call
        membership.reload
        expect(membership.amount_paid).to eq original_price
      end
    end
  end

  context 'when the changes are invalid' do
    let(:data) {{
      name: ''
    }}

    it 'does not save changes to the MembershipType record' do
      subject.call
      membership_type.reload
      expect(membership_type.name).not_to eq data[:name]
    end

    it 'does not call the success handler' do
      subject.call
      expect(success_handler).not_to have_received(:call)
    end

    it 'calls the error handler with the invalid membership type' do
      subject.call
      expect(error_handler).to have_been_called_with(satisfy { |v|
        expect(v).to eq membership_type
        expect(v).to be_invalid
      })
    end
  end
end
