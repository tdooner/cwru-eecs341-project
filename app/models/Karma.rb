class Karma
	include DataMapper::Resource
    validates_with_method :unique

	property :from, Integer, :key => true #first user
	property :unto, Integer, :key => true
	property :type, Boolean

    def unique
        existing = Karma.get(self.from, self.unto)
        return true if !existing
        return [false, "User is already on your block list!"] if existing.type == false
        return [false, "User is already on your trusted list!"] if existing.type == true
    end
end

