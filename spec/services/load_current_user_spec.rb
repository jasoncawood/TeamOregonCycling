require 'rails_helper'

RSpec.describe LoadCurrentUser do
  let(:service_args) {{
    user_id: user_id,
    success: success_handler
  }}

  callback_double(:success_handler)

  context 'when the user id does not match an existing user' do
    let(:user_id) { 1 }

    it 'does not call the success handler' do
      subject.call
      expect(success_handler).not_to have_been_called
    end
  end

  context 'when the user id matches an existing user' do
    let!(:user) { create(:user) }

    let(:user_id) { user.id }

    context 'when the user has been discarded' do
      before do
        user.discard
      end

      it 'does not call the success handler' do
        subject.call
        expect(success_handler).not_to have_been_called
      end
    end

    context 'when the user has not been discarded' do
      it 'calls the success handler with the user' do
        subject.call
        expect(success_handler).to have_been_called_with(user)
      end
    end
  end
end
