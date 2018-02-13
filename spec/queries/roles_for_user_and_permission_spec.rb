require 'rails_helper'

RSpec.describe Queries::RolesForUserAndPermission do
  subject { described_class.new(**query_args) }

  let(:query_args) {{
    user: user,
    permission: permission,
    result: result_callback
  }}

  let(:result_callback) { instance_double('Proc', :result, call: nil) }

  shared_examples_for :it_counts_the_results do
    it 'calls the result callback with the expected number of results' do
      subject.count
      expect(result_callback).to have_received(:call).with(expected_count)
    end
  end

  context 'when the specified user does not exist' do
    let(:user) { User.new }
    let(:permission) { :does_not_matter }
    let(:expected_count) { 0 }

    it_behaves_like :it_counts_the_results
  end
end
