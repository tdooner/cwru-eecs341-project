class User
	include DataMapper::Resource
	attr_accessor :password, :password_repeat
	attr_accessor :city, :state, :zip
	validates_presence_of :name, :address, :email
	validates_confirmation_of :password, :confirm => :password_repeat

	property :id, Serial
	property :name, String
	property :address, String
	property :location_id, Integer
	property :email, String
	property :created_at, DateTime
	property :password_hash, String 

	def password=(value)
		self.password_hash = Digest::SHA1.hexdigest(value)
	end

	has n, :items
	has n, :borrowings
	has n, :items, :through => :borrowings
end

