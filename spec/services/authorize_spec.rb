require 'services/authorize'

RSpec.describe Services::Authorize do
  subject { described_class.new(**service_args) }

  let(:service_args) {{
    context: user,
    logger: logger,
    permission: permission,
    authorized: authorized,
    not_authorized: not_authorized
  }}

  let(:user) { instance_double('User') }
  let(:logger) { instance_double('Logger').as_null_object }
  let(:permission) { :some_permission }
  let(:authorized) { instance_double('Proc', :authorized, call: nil) }
  let(:not_authorized) { instance_double('Proc', :not_authorized, call: nil) }

  let!(:roles_for_user_and_permission) {
    class_double('Queries::RolesForUserAndPermission').tap do |q|
      q.as_stubbed_const
      allow(q).to receive(:count)
    end
  }

  it 'fetches the number of roles that are both assigned to the context and ' \
     'include the given permission' do
    subject.call
    expect(roles_for_user_and_permission).to have_received(:count).with(
      user: user, permission: permission, result: subject.callback(:roles_counted)
    )
  end

  context 'when there are no roles assigned to the context with the given permission' do
    before do
      allow(roles_for_user_and_permission).to receive(:count) { |result:, **_|
        result.call(0)
      }
    end

    it 'calls the not_authorized callback' do
      subject.call
      expect(not_authorized).to have_received(:call)
    end

    it 'does not call the authorized callback' do
      subject.call
      expect(authorized).not_to have_received(:call)
    end
  end

  context 'when there is at least one role assigned to the context with the given permission' do
    before do
      allow(roles_for_user_and_permission).to receive(:count) { |result:, **_|
        result.call(1)
      }
    end

    it 'does not call the not_authorized callback' do
      subject.call
      expect(not_authorized).not_to have_received(:call)
    end

    it 'calls the authorized callback' do
      subject.call
      expect(authorized).to have_received(:call)
    end
  end
end
