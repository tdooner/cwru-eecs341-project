class Location
	include DataMapper::Resource

	property :zip_code, Integer, :key => true
	property :description, Text
	property :created_on, Date
end
