class Community
	include DataMapper::Resource
	validates_presence_of :name
	validates_numericality_of :zip

  property :id, Serial
  property :name, String
	property :zip, Integer
	property :description, Text
	property :created_on, Date

	has n, :users
end
