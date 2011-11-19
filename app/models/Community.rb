class Community
	include DataMapper::Resource
    validates_presence_of :name
    validates_numericality_of :zip_code

    property :id, Serial
    property :name, String
	property :zip_code, Integer
	property :description, Text
	property :created_on, Date
end
