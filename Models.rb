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

class Item
	include DataMapper::Resource

	property :id, Serial
	property :value, Float #need extended data types for this to be correct
	property :created_at, DateTime
	property :max_loan, Integer #Consider renaming/changing datatype
	property :user_id, Integer
end

class Borrowing
	include DataMapper::Resource

	property :borrow_id, Serial
	property :user_id, Integer
	property :item_id, Integer
end

class Issue #Issue should not map user to user, just exist and have a join
	include DataMapper::Resource

	property :issue_id, Serial
	property :created_at, DateTime
end

class Parties #Need this to map issues to users
	include DataMapper::Resource

	property :party_id, Serial #Will this end up needing a unique id?
	property :issue_id, Integer
	property :user_id, Integer
end

class Message
	include DataMapper::Resource

	property :message_id, Serial
	property :body, Text
	property :created_at, DateTime
	property :sender, Integer #user_id1
	property :reciever, Integer #user_id2
end

DataMapper.finalize
DataMapper.auto_migrate!
