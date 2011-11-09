class Media
	include DataMapper::Resource

	property :media_id, Serial
	property :item_id, Integer
	property :media_location, String #later make this a url field
end

