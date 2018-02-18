require 'rails_helper'

RSpec.describe Admin::DeleteUser do
  subject { described_class.new(**service_args) }

  let(:service_args) {{
    context: user,
    logger: logger,
    user: user_to_delete,
    success: success
  }}

  let(:user) { create(:user) }
  let(:logger) { instance_double('Logger').as_null_object }
  let(:user_to_delete) { create(:user) }
  let(:success) { instance_double('Proc', 'success', call: nil) }

  let!(:authorizer) {
    class_double('Authorize').tap do |s|
      s.as_stubbed_const
      allow(s).to receive(:call).with(context: user, logger: logger,
                                      permission: :delete,
                                      authorized: duck_type(:call),
                                      not_authorized: duck_type(:call),
                                      on: user_to_delete) { |authorized:, **_|
        authorized.call
      }
    end
  }

  shared_examples_for :it_deletes_the_user do
    it 'calls the success callback with the user that was destroyed' do
      subject.call
      expect(success).to have_received(:call).with(user_to_delete)
    end

    it 'discards the specified user' do
      subject.call
      expect(User.kept.where(id: user_to_delete.id).count).to eq 0
    end

    it 'does not fully delete the specified user' do
      subject.call
      expect(User.discarded.where(id: user_to_delete.id).count).to eq 1
    end
  end

  context 'when the user to delete is passed as a User object' do
    it_behaves_like :it_deletes_the_user
  end

  context 'when the user to delete is passed as an id' do
    before do
      service_args[:user] = user_to_delete.id
    end

    it_behaves_like :it_deletes_the_user
  end
end
