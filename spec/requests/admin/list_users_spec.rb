require 'rails_helper'

RSpec.describe 'Admin: List Users' do
  context 'an anonymous user' do
    specify 'is redirected to the login page' do
      get '/admin/users'
      expect(response).to redirect_to new_user_session_path
    end
  end

  context 'logged in' do
    before do
      sign_in user
    end

    let(:user) {
      attrs = {
        email: 'nobody@example.com',
        password: 'This is a bad password!'
      }
      User.create!(attrs) { |u| u.confirm }
    }

    context 'the current user does not have the :manage_users permission' do
      specify 'responds with a :forbidden status' do
        get '/admin/users'
        expect(response).to have_http_status :forbidden
      end
    end
  end
end
