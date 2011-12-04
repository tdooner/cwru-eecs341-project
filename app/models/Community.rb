class Community
	include DataMapper::Resource
    validates_presence_of :name, :zip_code

    property :id, Serial
    property :name, String
	property :zip_code, String, :format => /^\d{5}$/
	property :description, Text
	property :created_on, Date

    def latitude
        repository.adapter.select("select z.latitude from zip_codes z where zip=? limit 1",self.zip)[0] || 0
    end
    def longitude
        repository.adapter.select("select z.longitude from zip_codes z where zip=? limit 1",self.zip)[0] || 0
    end
end
