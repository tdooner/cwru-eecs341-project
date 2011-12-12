class Review
	include DataMapper::Resource

	property :body, Text
	property :created_at, DateTime
	property :user_id, Integer, :key => true
	property :item_id, Integer, :key => true

	belongs_to :user
	belongs_to :item
  has n, :helpful
end
