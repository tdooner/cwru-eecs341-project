class Message
	include DataMapper::Resource

	property :id, Serial
	property :body, Text
	property :created_at, DateTime
	property :sender, Integer #user_id1
	property :receiver, Integer #user_id2
end

