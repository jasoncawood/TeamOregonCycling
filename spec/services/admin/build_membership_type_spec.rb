require 'rails_helper'

RSpec.describe Admin::BuildMembershipType do
  let(:service_args) {{
    success: success_handler
  }}

  let(:context_user) { instance_double('User') }

  callback_double(:success_handler)

  service_double(:authorizer, 'Authorize') { |authorized:, **_|
    authorized.call
  }

  it_requires_permission :manage_users

  it 'calls the success handler with an instance of MembershipType' do
    subject.call
    expect(success_handler).to have_been_called_with(satisfy { |v|
      expect(v).to be_a MembershipType
      expect(v).to be_new_record
    })
  end

  it 'sets the MembershipType#position to the next-highest position' do
    create(:membership_type, position: 6)
    subject.call
    expect(success_handler).to have_been_called_with(satisfy { |v|
      expect(v.position).to eq 7
    })
  end
end
