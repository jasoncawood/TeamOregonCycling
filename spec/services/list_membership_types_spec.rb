require 'rails_helper'

RSpec.describe ListMembershipTypes do
  let(:service_args) {{
    with_result: result_handler
  }}

  callback_double(:result_handler, :each_handler)

  service_double(:authorizer, 'Authorize') { |authorized:, **_|
    authorized.call
  }

  let!(:mtype_a) { create(:membership_type, name: 'a') }
  let!(:mtype_b) { create(:membership_type, name: 'b') }
  let!(:mtype_c) { create(:membership_type, name: 'c') }

  before do
    mtype_b.insert_at(1)
    mtype_a.insert_at(2)
    mtype_c.insert_at(3)
  end

  shared_examples_for :it_calls_the_result_handler do
    specify {
      subject.call
      expect(result_handler)
        .to have_been_called_with([mtype_b, mtype_a, mtype_c])
    }
  end

  it_behaves_like :it_calls_the_result_handler

  it 'does not add discarded records to the results' do
    mtype_a.discard
    subject.call
    expect(result_handler)
      .to have_been_called_with([mtype_b, mtype_c])
  end

  context 'when with_each is specified' do
    before do
      service_args[:with_each] = each_handler
    end

    it 'yields each membership type to the handler in order of position' do
      subject.call
      expect(each_handler).to have_been_called_with(mtype_b).ordered
      expect(each_handler).to have_been_called_with(mtype_a).ordered
      expect(each_handler).to have_been_called_with(mtype_c).ordered
    end

    it_behaves_like :it_calls_the_result_handler
  end

  context 'when only_deleted is true' do
    before do
      service_args[:only_deleted] = true
      mtype_a.discard
      mtype_b.discard
    end

    it_requires_permission :manage_users

    it 'only adds discarded records to the result' do
      subject.call
      expect(result_handler)
        .to have_been_called_with([mtype_b, mtype_a])
    end
  end
end
