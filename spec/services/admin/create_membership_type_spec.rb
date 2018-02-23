require 'rails_helper'

RSpec.describe Admin::CreateMembershipType do
  let(:service_args) {{
    data: data,
    success: success_handler,
    error: error_handler
  }}

  let(:context_user) { instance_double('User') }

  let(:data) { Hash[] }

  callback_double(:success_handler, :error_handler)

  service_double(:authorizer, 'Authorize') { |authorized:, **_|
    authorized.call
  }

  it_requires_permission :manage_users

  context 'when the data results in an invalid MembershipType' do
    it 'does not create a new MembershipType' do
      expect { subject.call }.not_to change { MembershipType.count }
    end

    it 'does not call the success_handler' do
      subject.call
      expect(success_handler).not_to have_received(:call)
    end

    it 'calls the error handler with the invalid MembershipType' do
      subject.call
      expect(error_handler).to have_been_called_with(satisfy { |v|
        expect(v).to be_a MembershipType
        expect(v).to be_invalid
      })
    end
  end

  context 'when the data results in a valid MembershipType' do
    let(:data) { Hash[
      name: "Type #{SecureRandom.uuid}",
      description: 'Blah blah blah',
      price: 12.95,
      approval_required: false,
      position: 5
    ]}

    it 'does not call the error_handler' do
      subject.call
      expect(error_handler).not_to have_received(:call)
    end

    it 'calls the success_handler with the new MembershipType' do
      subject.call
      expect(success_handler).to have_been_called_with(an_instance_of(MembershipType))
    end

    it 'persists the new MembershipType' do
      result = nil
      allow(success_handler).to receive(:call) { |mtype|
        result = mtype
      }
      subject.call
      expect(result).to eq MembershipType.find(result.id)
      expect(result.name).to eq data[:name]
      expect(result.description).to eq data[:description]
      expect(result.price).to eq Money.from_amount(data[:price])
      expect(result.approval_required).to be false
      expect(result.position).to eq 5
    end

    context 'when assigned the same position as an existing item' do
      let!(:existing) { create(:membership_type, position: 5) }

      it 'inserts the new item in the specified position' do
        subject.call
        expect(success_handler).to have_been_called_with(satisfy { |v|
          v.position == 5
        })
      end

      it 'increments the position of the existing item' do
        subject.call
        existing.reload
        expect(existing.position).to eq 6
      end
    end
  end
end
