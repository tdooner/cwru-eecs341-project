require 'carrierwave/datamapper'

class ItemImageUploader < CarrierWave::Uploader::Base 
  include CarrierWave::MiniMagick 

  storage :file

  def store_dir 
    "#{Dir.pwd}/public/uploads/items/#{model.id}/image" 
  end 

  def extensions_white_list 
    %w(jpg jpeg gif png) 
  end 

  def default_url
    "/default.png"
  end

  process :resize_to_limit => [720,720] 
  version :icon40 do 
    process :resize_to_fill => [40,40] 
  end 
  version :icon60 do 
    process :resize_to_fill => [60,60] 
  end 
  version :thumb do 
    process :resize_to_limit => [210, 150] 
  end 

  version :profile do
    process :resize_to_limit => [300, 300]
  end
end




class Item
  include DataMapper::Resource
  validates_presence_of :name, :value, :max_loan

  property :id, Serial
  property :value, Decimal, :precision => 6, :scale => 2
  property :created_at, DateTime
  property :max_loan, Integer #Consider renaming/changing datatype
  property :name, String
  property :desc, Text
  mount_uploader :image, ItemImageUploader

  belongs_to :user
  has n, :borrowings, :constraint => :destroy
  has n, :reviews, :constraint => :destroy
  has n, :tags, {:through => Resource, :constraint => :skip}
  has n, :alerts, :constraint => :destroy

  before :destroy do
    self.tags.clear
    save
  end

  def available?
    return self.borrowings(:current => true).empty?
  end

  def currently_has
    return self.borrowings(:current => true).user.first
  end

  def printvalue
    if self.value
      return "%01.2f" % self.value
    else
      return ""
    end
  end

  def get_similar(n, tags)
    tags ||= self.tags
    ret = Set.new
    tags.each do |tag|
      thistag = tag.items(:limit => (n - ret.size + 1))#add 1 to account for self
      thistag.delete(self)
      ret.merge thistag
      if ret.size >= n
        return ret.to_a[0..n-1]
      end
    end 
    # if the array couldn't be filled with just similar items
    # fill it with other items
    ret.merge( Item.first(n - ret.size) )
    return ret.to_a[0..n-1]
  end

  def trusted_by?(user)
    return false unless user
    user.karmas.select{|x| x.type == true}.map{|x| x.unto}.include?(self.user_id)
  end
end

