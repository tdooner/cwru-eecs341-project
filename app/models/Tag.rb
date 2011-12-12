class Tag
	include DataMapper::Resource

  validates_uniqueness_of :name

	property :id, Serial
	property :name, String

	has n, :items, :through => Resource
end

