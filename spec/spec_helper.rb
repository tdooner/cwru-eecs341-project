$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'app')  # spec/../app/

require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)
require 'sinatra'
require 'rspec'
require 'rack/test'
require 'sharematch'    # app/sharematch.rb

# set test environment
Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false

# establish in-memory database for testing
DataMapper.setup(:default, "sqlite3::memory:")

RSpec.configure do |config|
  # reset database before each example is run
  config.before(:each) { DataMapper.auto_migrate!; DataMapper.finalize }
end

