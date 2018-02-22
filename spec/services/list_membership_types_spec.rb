require 'rails_helper'

RSpec.describe ListMembershipTypes do
  let(:service_args) {{
    with_each: each_handler
  }}

  callback_double(:each_handler)

  let!(:mtype_a) { create(:membership_type, weight: 2) }
  let!(:mtype_b) { create(:membership_type, weight: 1) }
  let!(:mtype_c) { create(:membership_type, weight: 3) }

  it 'yields each membership type to the handler in order of weight' do
    subject.call
    expect(each_handler).to have_been_called_with(mtype_b).ordered
    expect(each_handler).to have_been_called_with(mtype_a).ordered
    expect(each_handler).to have_been_called_with(mtype_c).ordered
  end
end
