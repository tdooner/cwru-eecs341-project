class Helpful
	include DataMapper::Resource

	property :review_id, Integer, :key => true
	property :user_id, Integer, :key => true
	property :helpful, Boolean
end

