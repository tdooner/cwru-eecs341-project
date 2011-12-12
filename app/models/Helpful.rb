class Helpful
	include DataMapper::Resource

	property :helpful, Boolean

  belongs_to :review, :key => true
  belongs_to :user, :key => true
end

