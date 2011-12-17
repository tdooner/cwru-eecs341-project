class Review
	include DataMapper::Resource

    property :id, Serial
	property :body, Text
	property :created_at, DateTime

	belongs_to :user
	belongs_to :item

        validates_uniqueness_of :user, :scope => :item
  has n, :helpfuls

  def upDownVotes
    self.helpfuls.reduce({:up => 0, :down => 0}) do |result, hf|
      if hf.helpful
        result[:up] += 1
      else
        result[:down] += 1
      end
      result
    end
  end
end
