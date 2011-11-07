require 'rubygems'
require 'data_mapper'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/test.db")

class User
	include DataMapper::Resource

	property :id, Serial
	property :name, String
	property :address, String
	property :location_id, Integer
	property :email, String
	property :joined_at, DateTime
	property :password, String #later make this bcrypthash

	has n, :items
	has n, :borrowings
end

class Item
	include DataMapper::Resource

	property :id, Serial
	property :value, Decimal, :precision => 6, :scale => 2
	property :created_at, DateTime
	property :max_loan, Integer #Consider renaming/changing datatype

	belongs_to :user
	has n, :borrowings
end

class Borrowing
	include DataMapper::Resource

	property :borrow_id, Serial
	property :created_at, DateTime 
	property :item_id, Integer

	belongs_to :user
	belongs_to :item
	has n, :issues
end

class Issue #Issue should not map user to user, just exist and have a join
	include DataMapper::Resource

	property :issue_id, Serial
	property :created_at, DateTime

	belongs_to :borrowing
end

class Parties #Need this to map issues to users
	include DataMapper::Resource

	property :issue_id, Integer, :key => true
	property :user_id, Integer, :key => true
end

class Message
	include DataMapper::Resource

	property :message_id, Serial
	property :body, Text
	property :created_at, DateTime
	property :sender, Integer #user_id1
	property :receiver, Integer #user_id2
end

class Karma
	include DataMapper::Resource

	property :from, Integer, :key => true #first user
	property :unto, Integer, :key => true
	property :type, Boolean
end

class Tag
	include DataMapper::Resource

	property :tag_id, Serial
	property :name, String
end

class Tagging 
	include DataMapper::Resource

	property :item_id, Integer, :key => true
	property :tag_id, Integer, :key => true
end

class Media
	include DataMapper::Resource

	property :media_id, Serial
	property :item_id, Integer
	property :media_location, String #later make this a url field
end

class Location
	include DataMapper::Resource

	property :zip_code, Integer, :key => true
	property :description, Text
	property :created_on, Date
end

class Review
	include DataMapper::Resource

	property :item_id, Integer, :key => true
	property :user_id, Integer, :key => true
	property :body, Text
end

class Helpful
	include DataMapper::Resource

	property :review_id, Integer, :key => true
	property :user_id, Integer, :key => true
	property :helpful, Boolean
end

DataMapper.finalize
DataMapper.auto_migrate!
