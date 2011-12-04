class Community
	include DataMapper::Resource
    validates_presence_of :name, :zip_code

    property :id, Serial
    property :name, String
	property :zip_code, String, :format => /^\d{5}$/
	property :description, Text
	property :created_on, Date
end
