class Helpful
	include DataMapper::Resource

	property :helpful, Boolean
	property :review_id, Integer, :key => true 
	property :user_id, Integer, :key => true 

	belongs_to :review
	belongs_to :user
end

