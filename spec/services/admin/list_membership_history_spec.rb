require 'rails_helper'

RSpec.describe Admin::ListMembershipHistory do
  let(:service_args) {{
    user: user,
    with_result: result_handler
  }}

  let(:context_user) { create(:user) }
  let(:user) { create(:user) }
  let!(:membership_1) {
    create(:membership, user: user, ends_on: Date.civil(2018,1,1))
  }
  let!(:membership_2) {
    create(:membership, user: user, ends_on: Date.civil(2017,12,31))
  }
  let(:result_handler) { ->(user) { @result = user } }
  let(:result) { @result }

  service_double(:authorizer, 'Authorize') { |authorized:, **_|
    authorized.call
  }

  it_requires_permission :view_membership_history, on: :user

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
