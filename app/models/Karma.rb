class Karma
	include DataMapper::Resource

	property :from, Integer, :key => true #first user
	property :unto, Integer, :key => true
	property :type, Boolean
end

