class Tagging 
	include DataMapper::Resource

	property :item_id, Integer, :key => true
	property :tag_id, Integer, :key => true
end
