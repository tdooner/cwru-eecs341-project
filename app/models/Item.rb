class Item
	include DataMapper::Resource
	validates_presence_of :name, :value, :max_loan

	property :id, Serial
	property :value, Decimal, :precision => 6, :scale => 2
	property :created_at, DateTime
	property :max_loan, Integer #Consider renaming/changing datatype
	property :name, String

	belongs_to :user
	has n, :borrowings
	has n, :users, :through => :borrowings
end

