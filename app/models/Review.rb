class Review
	include DataMapper::Resource

	property :item_id, Integer, :key => true
	property :user_id, Integer, :key => true
	property :body, Text
end
