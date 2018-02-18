require 'rails_helper'

RSpec.describe Admin::ListMembershipHistory do
  subject { described_class.new(**service_args) }

  let(:service_args) {{
    context: context_user,
    logger: logger,
    user: user,
    with_result: result_handler
  }}

  let(:context_user) { create(:user) }
  let(:logger) { instance_double('Logger').as_null_object }
  let(:user) { create(:user) }
  let!(:membership_1) {
    create(:membership, user: user, ends_on: Date.civil(2018,1,1))
  }
  let!(:membership_2) {
    create(:membership, user: user, ends_on: Date.civil(2017,12,31))
  }
  let(:result_handler) { ->(user) { @result = user } }
  let(:result) { @result }
  let!(:authorizer) {
    class_double('Authorize').tap do |s|
      s.as_stubbed_const
      allow(s).to receive(:call) { |authorized:, **_|
        authorized.call
      }
    end
  }

  it 'requires the :view_membership_history permission on the target user' do
    subject.call
    expect(authorizer).to have_received(:call).with(
      context: context_user,
      logger: logger,
      permission: :view_membership_history,
      on: user,
      authorized: duck_type(:call),
      not_authorized: duck_type(:call)
    )
  end

  context 'when user is passed as a User object' do
    it 'provides the users memberships in descending order by end date' do
      subject.call
      expect(result).to eq [membership_1, membership_2]
    end
  end

  context 'when user is passed as an ID' do
    before do
      service_args[:user] = user.id
    end

    it 'provides the users memberships in descending order by end date' do
      subject.call
      expect(result).to eq [membership_1, membership_2]
    end
  end
end
