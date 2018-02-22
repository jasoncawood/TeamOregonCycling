RSpec.describe Admin::DeterminePrimaryAdminScreen do
  let(:service_args) {{
    url_generator: url_generator,
    with_result: result_handler,
    nothing_available: nothing_available_handler
  }}

  callback_double(:result_handler, :nothing_available_handler)
  callback_double(:url_generator, return_value: '/generated/url')
  service_double(:authorizer, 'Authorize')

  shared_examples_for :it_provides_a_result_for do |**url_args|
    it 'calls the url_generator for the admin/users#index action' do
      subject.call
      expect(url_generator)
        .to have_been_called_with(**url_args)
    end

    it 'calls the result handler with the generated url' do
      subject.call
      expect(result_handler).to have_been_called_with('/generated/url')
    end

    it 'does not call the nothing available handler' do
      subject.call
      expect(nothing_available_handler).not_to have_received(:call)
    end
  end

  context 'when the context user has no admin permissions' do
    it 'calls the nothing_available_handler' do
      subject.call
      expect(nothing_available_handler).to have_received(:call)
    end

    it 'does not call the result_handler' do
      subject.call
      expect(result_handler).not_to have_received(:call)
    end
  end

  context 'when the user has the :manage_users permission' do
    before do
      stub_service_call(authorizer, permission: :manage_users) { |authorized:, **_|
        authorized.call
      }
    end

    it_behaves_like :it_provides_a_result_for, controller: 'admin/users',
      action: 'index'
  end
end
