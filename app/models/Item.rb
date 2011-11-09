class Item
	include DataMapper::Resource

	property :id, Serial
	property :value, Decimal, :precision => 6, :scale => 2
	property :created_at, DateTime
	property :max_loan, Integer #Consider renaming/changing datatype

	belongs_to :user
	has n, :borrowings
	has n, :users, :through => :borrowings
end

