require 'rubygems'
require 'dm-core'
require 'dm-migrations'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/test.db")

class User
	include DataMapper::Resource

	property :id, Serial
	property :name, String
	property :address, String
	property :email, String
	property :joined_at, DateTime
	property :password, Integer
end


DataMapper.finalize
DataMapper.auto_migrate!
