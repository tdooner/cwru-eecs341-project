require 'rubygems'
require 'data_mapper'
require 'mixpanel'

require 'sinatra' unless defined?(Sinatra)

configure do
  # load models
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/models")
  Dir.glob("#{File.dirname(__FILE__)}/models/*.rb") { |lib| require File.basename(lib, '.*') }

  DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/#{Sinatra::Base.environment}.db")
  DataMapper.finalize


end

