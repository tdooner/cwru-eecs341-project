class Borrowing
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime 
  property :returned_at, DateTime, :required => false
  property :current, Boolean, :default => true

  belongs_to :user
  belongs_to :item
  has n, :issues, :constraint => :destroy

  validates_with_block do
    if Borrowing.get(:current => true, :item => self.item, :id.not => self.id).nil?
      true
    else
      [false, "There can only be one person borrowing an item at a time."]
    end
  end

  def days_remaining
    self.created_at + self.item.max_loan - DateTime.now
  end
end

