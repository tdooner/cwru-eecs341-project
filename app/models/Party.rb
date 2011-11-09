class Party #Need this to map issues to users
	include DataMapper::Resource

	property :issue_id, Integer, :key => true
	property :user_id, Integer, :key => true
end

