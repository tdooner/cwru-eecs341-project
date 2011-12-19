require 'bcrypt'
require 'haversine'

class User
  include DataMapper::Resource
  include BCrypt
  attr_accessor :password, :password_repeat

  validates_presence_of :name, :address, :email, :city, :state, :zip
  validates_format_of :email, :as => :email_address
  validates_uniqueness_of :email
  validates_format_of :zip, :with => /^\d{5}(-\d{4})?$/
  validates_with_method :passwords_match
  validates_with_method :password_not_nil

  property :id, Serial
  property :name, String
  property :address, String
  property :city, String
  property :state, String
  property :zip, String
  property :location_id, Integer
  property :email, String
  property :created_at, DateTime
  property :password_hash, BCryptHash
  property :is_admin, Boolean

  has n, :items, :constraint => :destroy
  has n, :borrowings, :constraint => :destroy
  has n, :helpfuls, :constraint => :destroy
  has n, :karmas, {:child_key=>:from, :constraint => :destroy}
  has n, :reviews, :constraint => :destroy
  has n, :alerts, :constraint => :destroy

  belongs_to :community, :required => false

  def password=(new_password)
    return if new_password.to_s.empty?
    self.instance_variable_set(:@password, new_password)
    self.password_hash = Password.create(new_password)
  end

  def passwords_match
    return true if self.password == self.password_repeat
  end

  def password_not_nil
    # If this is an unsaved user, the password should not be nil
    return true unless self.id.nil?
    if self.password.to_s.empty? or self.password_repeat.to_s.empty?
      return [false, "Password cannot be empty!"]
    else
      return true
    end
  end

  def forgot_password
    random_password = Array.new(10).map { (65 + rand(58)).chr }.join
    self.password = random_password
    self.save!
    return random_password
  end

  def closest_communities
    begin
      communities = repository.adapter.select("select c.id, z.latitude, z.longitude, z.latitude-(select latitude from zip_codes where zip = ?) as latdiff, z.longitude-(select longitude from zip_codes where zip = ?) as londiff FROM zip_codes z, communities c WHERE c.zip = z.zip ORDER BY latdiff*latdiff+londiff*londiff ASC;",self.zip,self.zip);
      # Return the Haversine difference, a great-circle distance.
      communities.map{|x| 
        c = Community.get(x.id)

        {:community => c, :distance=>Haversine.distance(self.latitude, self.longitude, x.latitude, x.longitude)}
      }.sort{|x,y| x[:distance] <=> y[:distance]}
    rescue
      Community.all.map{|x| {:community => x, :distance=>Haversine.distance(0,0,0,0)}}
    end
  end

  def latitude
    repository.adapter.select("select z.latitude from zip_codes z where zip=? limit 1",self.zip)[0] || 0
  end
  def longitude
    repository.adapter.select("select z.longitude from zip_codes z where zip=? limit 1",self.zip)[0] || 0
  end

  def distance_from(zip)
    pos = repository.adapter.select("select latitude, longitude from zip_codes where zip = ?;", zip)
    return Haversine.distance(self.latitude, self.longitude, pos[0].latitude, pos[0].longitude)
  end
end

