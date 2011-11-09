class Tag
	include DataMapper::Resource

	property :tag_id, Serial
	property :name, String
end

