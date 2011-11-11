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
	property :salt, String
        property :is_admin, Boolean

	has n, :items
	has n, :borrowings
	has n, :items, :through => :borrowings

	def self.authenticate(email, pass)
		current_user = first(:email => email)
		return nil if current_user.nil? || User.encrypt(pass, current_user.salt) != current_user.password_hash
		current_user
	end  

	def password=(pass)
		self.salt = (1..12).map{(rand(26)+65).chr}.join if !self.salt
		self.password_hash = User.encrypt(pass, self.salt)
	end

	protected
	def self.encrypt(pass, salt)
		Digest::SHA1.hexdigest(pass + salt)
	end
end

