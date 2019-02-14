ruby '2.6.0'
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'active_model_validates_intersection_of'
gem 'acts_as_list'
gem 'bcrypt'
gem 'bootstrap'
gem 'braintreehttp'
gem 'coffee-rails'
gem 'discard', github: 'jhawthorn/discard', branch: 'master'
gem 'jbuilder'
gem 'jquery-rails'
gem 'mail_form'
gem 'money-rails'
gem 'new_google_recaptcha'
gem 'octicons_helper'
gem 'paypal-checkout-sdk', require: 'paypal-checkout-sdk'
gem 'pg'
gem 'popper_js'
gem 'puma'
gem 'rails'
gem 'redcarpet'
gem 'sassc-rails'
gem 'scenic'
gem 'simple_form'
gem 'the_help'
gem 'timber', '~> 2.6'
gem 'uglifier'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-rspec'
end

group :test do
  gem 'rails-controller-testing'
end

group :development do
  gem 'foreman'
  gem 'listen'
  gem 'web-console'
end
