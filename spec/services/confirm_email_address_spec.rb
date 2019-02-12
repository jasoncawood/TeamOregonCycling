require 'services/confirm_email_address'

RSpec.describe ConfirmEmailAddress do
  let(:service_args) {{
    confirmation_token: confirmation_token,
    email_confirmed: email_confirmed_handler,
    invalid: invalid_handler,
    clock: clock
  }}

  let(:confirmation_token) { '12345' }

  callback_double(:email_confirmed_handler, :invalid_handler)

  let!(:users_repo) {
    class_double('User').tap do |r|
      r.as_stubbed_const
      allow(r).to receive(:find_by).and_return(user)
    end
  }

  let(:user) {
    instance_double('User', update_attributes!: nil)
  }

  let(:clock) {
    class_double('Time').tap do |t|
      allow(t).to receive(:now).and_return(Time.new(2019, 1, 1))
    end
  }

  it 'looks for a user with the specified confirmation code' do
    subject.call
    expect(users_repo)
      .to have_received(:find_by).with(confirmation_token: confirmation_token)
  end

  context 'when no user matches the confirmation code' do
    before do
      allow(users_repo).to receive(:find_by).and_return(nil)
    end

    it 'calls the invalid callback' do
      subject.call
      expect(invalid_handler).to have_been_called
    end

    it 'does not call the email_confirmed callback' do
      subject
      expect(email_confirmed_handler).not_to have_been_called
    end
  end

  context 'when a user matches the confirmation code' do
    it 'sets confirmed_at to the current time and removes the confirmation code' do
      subject.call
      expect(user).to(
        have_received(:update_attributes!)
        .with(confirmation_token: nil, confirmed_at: clock.now)
      )
    end

    it 'does not call the invalid callback' do
      subject.call
      expect(invalid_handler).not_to have_been_called
    end

    it 'calls the email_confirmed callback' do
      subject.call
      expect(email_confirmed_handler).to have_been_called
    end
  end
end
