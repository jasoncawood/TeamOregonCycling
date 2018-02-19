require 'rails_helper'

RSpec.describe ListMembershipTypes do
  subject { described_class.new(**service_args) }

  let(:service_args) {{
    context: context_user,
    logger: logger,
    with_each: each_handler
  }}

  let(:context_user) { instance_double('User') }
  let(:logger) { instance_double('Logger').as_null_object }
  let(:each_handler) { instance_double('Proc', :with_each, call: nil) }

  let!(:mtype_a) { create(:membership_type, weight: 2) }
  let!(:mtype_b) { create(:membership_type, weight: 1) }
  let!(:mtype_c) { create(:membership_type, weight: 3) }

  it 'yields each membership type to the handler in order of weight' do
    subject.call
    expect(each_handler).to have_received(:call).with(mtype_b).ordered
    expect(each_handler).to have_received(:call).with(mtype_a).ordered
    expect(each_handler).to have_received(:call).with(mtype_c).ordered
  end
end
