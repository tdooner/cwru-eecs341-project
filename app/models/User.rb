class User
	include DataMapper::Resource

	property :id, Serial
	property :name, String
	property :address, String
	property :location_id, Integer
	property :email, String
	property :joined_at, DateTime
	property :password, String #later make this bcrypthash

	has n, :items
	has n, :borrowings
	has n, :items, :through => :borrowings
end

