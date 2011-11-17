require 'bcrypt'

class User
	include DataMapper::Resource
	include BCrypt
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
	property :password_hash, BCryptHash
	property :is_admin, Boolean

	has n, :items
	has n, :borrowings
	has n, :items, :through => :borrowings


	def password
		@password ||= Password.new(password_hash)
	end

	def password=(new_password)
		@password = Password.create(new_password)
		self.password_hash = @password
	end



end

