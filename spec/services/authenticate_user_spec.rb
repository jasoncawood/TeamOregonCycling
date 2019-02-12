require 'rails_helper'

RSpec.describe AuthenticateUser do
  let(:service_args) {{
    email: email,
    password: password,
    success: success_handler,
    email_not_confirmed: email_not_confirmed_handler,
    failed: failed_handler
  }}

  let!(:user) {
    create(:user, email: 'nobody@example.com', password: 'A c@@l p4ssw0rd.')
  }

  callback_double(:success_handler, :failed_handler,
                  :email_not_confirmed_handler)

  shared_examples_for :authentication_failed do
    it 'does not call the success callback' do
      subject.call
      expect(success_handler).not_to have_been_called
    end

    it 'does not call the email_not_confirmed callback' do
      subject.call
      expect(email_not_confirmed_handler).not_to have_been_called
    end

    it 'calls the failed callback' do
      subject.call
      expect(failed_handler).to have_been_called
    end
  end

  context 'when the email does not match that of an existing user' do
    let(:email) { 'wrong@example.com' }
    let(:password) { 'does not matter' }

    it_behaves_like :authentication_failed
  end

  context 'when the email matches that of an existing user' do
    let(:email) { 'nobody@example.com' }

    context 'when the password does not match' do
      let(:password) { 'not correct' }

      it_behaves_like :authentication_failed
    end

    context 'when the password does match' do
      let(:password) { 'A c@@l p4ssw0rd.' }

      context 'when the user has been discarded' do
        before do
          user.discard
        end

        it_behaves_like :authentication_failed
      end

      context 'when the user has not been discarded' do
        context 'when the users email address has not been confirmed' do
          it 'does not call the failed callback' do
            subject.call
            expect(failed_handler).not_to have_been_called
          end

          it 'does not call the success callback' do
            subject.call
            expect(success_handler).not_to have_been_called
          end

          it 'calls the email_not_confirmed callback' do
            subject.call
            expect(email_not_confirmed_handler).to have_been_called
          end
        end

        context 'when the users email address has been confirmed' do
          before do
            user.update_attributes!(confirmation_token: nil,
                                   confirmed_at: Time.now)
          end

          it 'does not call the failed callback' do
            subject.call
            expect(failed_handler).not_to have_been_called
          end

          it 'does not call the email_not_confirmed callback' do
            subject.call
            expect(email_not_confirmed_handler).not_to have_been_called
          end

          it 'calls the success callback with the user' do
            subject.call
            expect(success_handler).to have_been_called_with(user: user)
          end
        end
      end
    end
  end
end
