class Helpful
	include DataMapper::Resource

	property :helpful, Boolean

	belongs_to :review, :key => true

end

