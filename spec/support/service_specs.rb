RSpec.shared_context :service_specs do
  subject { described_class.new(**all_service_args) }

  let(:all_service_args) { default_service_args.merge(service_args) }

  let(:default_service_args) { Hash[
    context: context_user,
    logger: logger
  ]}

  let(:context_user) { nil }
  let(:logger) { instance_double('Logger').as_null_object }

  let(:service_args) { Hash.new }

  def self.callback_double(*names, return_value: nil)
    names.each do |name|
      let(name) { instance_double('Proc', name, call: return_value) }
    end
  end

  def self.service_double(name, constant, &block)
    let!(name) {
      class_double(constant).tap do |s|
        s.as_stubbed_const
        allow(s).to receive(:call, &block)
      end
    }
  end

  def self.it_requires_permission(permission, on: nil, authorizer: :authorizer)
    service_double(:authorizer, 'Authorize') do |authorized:, **_|
      authorized.call
    end

    name = "requires permission :#{permission}"
    name += " on #{on}" unless on.nil?
    it name do
      args = {permission: permission}
      args[:on] = send(on) unless on.nil?
      subject.call
      expect(send(authorizer)).to have_received_service_call(args).at_least(1)
    end
  end

  def stub_service_call(service, **args_to_match, &block)
    allow(service).to receive(:call).with(hash_including(args_to_match), &block)
  end

  def have_received_service_call(**service_args)
    have_received(:call)
      .with(hash_including(default_service_args.merge(service_args)))
  end

  def have_been_called_with(*args)
    have_been_called.with(*args)
  end

  def have_been_called
    have_received(:call)
  end
end
