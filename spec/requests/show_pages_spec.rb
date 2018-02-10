require 'rails_helper'

RSpec.describe 'Show pages' do
  context 'an anonymous user' do
    specify 'can view the home page' do
      get '/'
      expect(response).to render_template('pages/about_us')
    end

    specify 'can view about_us' do
      get '/pages/about_us'
      expect(response).to render_template('pages/about_us')
    end

    specify 'requesting an unknown page renders a 404' do
      get '/pages/thispagedoesnotexist'
      expect(response).to have_http_status :not_found
    end
  end
end
