$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'app')  # spec/../app/

require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)
require 'sinatra'
require 'rspec'
require 'capybara/rspec'
require 'rack/test'
require 'sharematch'    # app/sharematch.rb

# set test environment
Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false

Capybara.app = ShareMatch::App

# establish in-memory database for testing
DataMapper.setup(:default, "sqlite3::memory:")

# Helpers
def signup_page_one(user)
    visit '/sign-up'
    fill_in "name", :with => user[:name]
    fill_in "email", :with => user[:email]
    fill_in "password", :with => user[:password]
    fill_in "password_repeat", :with => user[:password_repeat]
    fill_in "address", :with => user[:address]
    fill_in "city", :with => user[:city]
    fill_in "zip", :with => user[:zip]
    click_button 'Sign Up'
end
def login(user)
    visit '/login'
    fill_in "uname", :with => user[:email]
    fill_in "password", :with => user[:password]
    click_button 'Login'
end

RSpec.configure do |config|
  # reset database before each example is run
  config.before(:each) { DataMapper.auto_migrate! }
end

