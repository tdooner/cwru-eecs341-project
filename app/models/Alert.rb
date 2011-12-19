class Alert
  include DataMapper::Resource

  property :id, Serial

  belongs_to :user
  belongs_to :item
  
  validates_uniqueness_of :user, :scope => :item
end

