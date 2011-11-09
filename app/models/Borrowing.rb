class Borrowing
	include DataMapper::Resource

	property :borrow_id, Serial
	property :created_at, DateTime 
	property :item_id, Integer

	belongs_to :user
	belongs_to :item
	has n, :issues
end

