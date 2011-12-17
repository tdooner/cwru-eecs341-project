class Issue 
	include DataMapper::Resource

	property :id, Serial
	property :created_at, DateTime
  property :resolved, Boolean, :default => false
  property :admin_notified, Boolean, :default => false

	belongs_to :borrowing

  def owner
    return self.borrowing.item.user
  end

  def borrower
    return self.borrowing.user
  end

  def item
    return self.borrowing.item
  end
end
