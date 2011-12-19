class Message
	include DataMapper::Resource

	property :id, Serial
	property :body, Text
	property :created_at, DateTime

  belongs_to :sender, 'User',
   :parent_key => [:id],
   :child_key =>[:sender_id],
   :required => true 


  belongs_to :receiver, 'User',
   :parent_key => [:id],
   :child_key =>[:receiver_id],
   :required => true 


  def self.convo(user1, user2)
    Message.all(:sender => user1, :receiver => user2, 
                :order => [:created_at.asc]) + Message.all(:sender => user2, 
                :receiver => user1, :order => [:created_at.asc])
  end
end

