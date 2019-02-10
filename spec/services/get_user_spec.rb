require 'rails_helper'

RSpec.describe GetUser do
  let(:service_args) {{
    user: user,
    with_result: result_handler
  }}

  let(:context_user) { create(:user) }
  let(:user) { create(:user) }
  let(:result_handler) { ->(user) { @result = user } }
  let(:result) { @result }

  service_double(:authorizer, 'Authorize') { |authorized:, **_|
    authorized.call
  }

  it_requires_permission :show, on: :user

  context 'when user is passed as a User object' do
    it 'provides that user as the result' do
      subject.call
      expect(result).to eq user
    end
  end

  context 'when user is passed as an ID' do
    before do
      service_args[:user] = user.id
    end

    it 'loads the user object and provides the user as the result' do
      subject.call
      expect(result).to eq user
    end
  end
end
