require 'services/check_membership_status'

RSpec.describe CheckMembershipStatus do
  let(:service_args) {{
    user: user_to_check,
    current: current_handler,
    expired: expired_handler,
    no_history: no_history_handler
  }}

  let(:user_to_check) {
    instance_double('User')
  }

  callback_double(:current_handler, :expired_handler, :no_history_handler)

  service_double(:list_membership_history, 'ListMembershipHistory')

  before do
    allow(list_membership_history).to receive(:call) { |with_result:, **_|
      with_result.call(history)
    }
  end

  let(:history) { [] }

  let(:expired_membership) {
    instance_double('Membership', expired?: true)
  }

  let(:valid_membership) {
    instance_double('Membership', expired?: false)
  }

  it_requires_permission :show, on: :user_to_check

  it 'retrieves the membership history for the user' do
    subject.call
    expect(list_membership_history)
      .to have_received_service_call(
        user: user_to_check,
        with_result: duck_type(:call)
      )
  end

  context 'when no membership is found' do
    it 'calls the no_history handler' do
      subject.call
      expect(no_history_handler).to have_been_called
    end

    it 'does not call the current handler' do
      subject.call
      expect(current_handler).not_to have_been_called
    end

    it 'does not call the expired handler' do
      subject.call
      expect(expired_handler).not_to have_been_called
    end
  end

  context 'when a membership is found, but it has already expired' do
    let(:history) { [expired_membership, valid_membership] }

    it 'does not call the no_history handler' do
      subject.call
      expect(no_history_handler).not_to have_been_called
    end

    it 'does not call the current handler' do
      subject.call
      expect(current_handler).not_to have_been_called
    end

    it 'calls the expired handler' do
      subject.call
      expect(expired_handler).to have_been_called_with(expired_membership)
    end
  end

  context 'when an unexpired membership is found' do
    let(:history) { [valid_membership, expired_membership] }

    it 'does not call the no_history handler' do
      subject.call
      expect(no_history_handler).not_to have_been_called
    end

    it 'calls the current handler' do
      subject.call
      expect(current_handler).to have_been_called_with(valid_membership)
    end

    it 'does not call the expired handler' do
      subject.call
      expect(expired_handler).not_to have_been_called
    end
  end
end
