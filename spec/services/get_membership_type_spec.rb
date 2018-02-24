require 'rails_helper'

RSpec.describe GetMembershipType do
  let(:service_args) {{
    membership_type: membership_type,
    with_result: result_handler,
    not_found: not_found_handler
  }}

  callback_double(:result_handler, :not_found_handler)

  service_double(:authorizer, 'Authorize') { |authorized:, **_|
    authorized.call
  }

  shared_examples_for :it_is_not_found do
    it 'calls the not_found handler' do
      subject.call
      expect(not_found_handler).to have_received(:call)
    end

    it 'does not call the result handler' do
      subject.call
      expect(result_handler).not_to have_received(:call)
    end
  end

  shared_examples_for :it_is_found do
    it 'calls the result handler with the existing membership type' do
      subject.call
      expect(result_handler).to have_been_called_with(existing_membership_type)
    end

    it 'does not call the not_found handler' do
      subject.call
      expect(not_found_handler).not_to have_received(:call)
    end
  end

  shared_examples_for :it_is_found_by_id_or_instance do
    context 'passed by ID' do
      let(:membership_type) { existing_membership_type.id }

      it_behaves_like :it_is_found
    end

    context 'passed by instance' do
      let(:membership_type) { existing_membership_type }

      it_behaves_like :it_is_found
    end
  end

  context 'with a non-existant membership type' do
    context 'passed by ID' do
      let(:membership_type) { 42 }

      it_behaves_like :it_is_not_found
    end

    context 'passed by instance' do
      let(:membership_type) { build(:membership_type) }

      it_behaves_like :it_is_not_found
    end
  end

  context 'with an existing membership type' do
    let(:existing_membership_type) { create(:membership_type) }

    context 'that is not discarded' do
      it_behaves_like :it_is_found_by_id_or_instance
    end

    context 'that has been discarded' do
      before do
        existing_membership_type.discard
      end

      context 'when the context user has the manage_users permission' do
        before do
          stub_service_call(authorizer, permission: :manage_users) { |authorized:, **_|
            authorized.call
          }
        end

        it_behaves_like :it_is_found_by_id_or_instance
      end

      context 'when the context user does not have the manage_users permission' do
        before do
          stub_service_call(authorizer, permission: :manage_users) { |not_authorized:, **_|
            not_authorized.call
          }
        end

        let(:membership_type) { existing_membership_type.id }

        it_behaves_like :it_is_not_found
      end
    end
  end
end
