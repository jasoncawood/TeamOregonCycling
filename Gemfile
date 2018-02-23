ruby "2.5.0"
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'active_model_validates_intersection_of'
gem 'acts_as_list'
gem 'bootstrap'
gem 'coffee-rails', '~> 4.2'
gem 'devise'
gem 'devise-bootstrapped', github: 'king601/devise-bootstrapped',
  branch: 'bootstrap4'
gem 'discard', github: 'jhawthorn/discard', branch: 'master'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'money-rails'
gem 'octicons_helper'
gem 'pg', '~> 0.18'
gem 'popper_js'
gem 'puma', '~> 3.7'
gem 'rails', '~> 5.1.4'
gem 'redcarpet'
gem 'sass-rails', '~> 5.0'
gem 'scenic'
gem 'simple_form'
gem 'the_help'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
end

group :test do
  gem 'rails-controller-testing'
end

group :development do
  gem 'foreman'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
end
