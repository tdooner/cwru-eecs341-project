require 'faker'

class Seed

  def self.run! count
    count = count.to_i
    self.communities
    self.users count
    self.items (count*4)
    self.borrows count
    self.issues count/2
    self.tags (count*8)
    self.reviews (count*16)
    self.helpfuls (count*32)
  end

  def self.communities
    Community.create(:name => 'Redmond, WA', :state => 'Washington', :zip => 98052, :description => 'Micro$oft!')
    Community.create(:name => 'Pittsburgh, PA',:state => 'Pennsylvania',  :zip => 15217, :description => 'Pittsburgh Steelers')
    Community.create(:name => 'Bolingbrook, IL', :state => 'Illinois', :zip => 60490, :description => 'Bolingbrook User Groups')
    Community.create(:name => 'San Francisco, CA',:state => 'California', :zip => 94108, :description => 'San Francisco is fun!')
    Community.create(:name => 'Macedonia, OH', :state => 'Ohio', :zip => 44056, :description => 'A nice place below Cleveland')
    Community.create(:name => 'Cleveland, OH', :state => 'Ohio',  :zip => 44106, :description => 'Home of Case Western Reserve University')
  end

  def self.users count
    comms = Community.all
    count.times do
      comm = comms[rand(comms.size)]
      name = Faker::Name.name
      User.create!(:name => name,
                   :address => Faker::Address.street_address,
                   :city => comm.name,
                   :state => comm.state,
                   :zip => comm.zip,
                   :community => comm,
                   :email => Faker::Internet.user_name(name) + "@example.com",
                   :password => 'password',
                   :password_repeat => 'password',
                   :is_admin => false,
                   :created_at => self.time_rand)
    end

    #now add a default admin
    comm = comms[rand(comms.size)]
    User.create!(:name => 'Admin',
                 :address => Faker::Address.street_address,
                 :city => comm.name,
                 :state => 'Ohio', #TODO: change this later
                 :zip => comm.zip,
                 :community => comm,
                 :email => 'admin@sharemat.ch',
                 :password => 'password',
                 :password_repeat => 'password',
                 :is_admin => true,
                 :created_at => self.time_rand)
  end

  def self.items count
    f = open('./script/common_items.yml')
    item_names = YAML::load(f)
    users = User.all
    images = Dir.glob("./script/images/*")
    count.times do
      user = users[rand(users.size)]

      f = {}
      path = images[rand(images.size)]
      f[:filename] = path.split('/')[-1]
      f[:type] = 'image/' + path.split('.')[-1]
      f[:name] = 'seed-image'
      f[:tempfile] = File.open(images[rand(images.size)])


      a = Item.new(:value => rand(500),
                   :max_loan => 1 + rand(20),
                   :name => item_names[rand(item_names.size)],
                   :desc => Faker::Lorem.paragraph(5),
                   :user => user,
                   :image => f,
                   :created_at => self.time_rand(user.created_at))
      a.save
    end
  end

  def self.borrows count
    items = Item.all
    users = User.all
    count.times do
      user = users[rand(users.size)]
      item = items[rand(items.size)]

      creation = self.time_rand([user.created_at, item.created_at].max)

      Borrowing.create(:user => user, :item => item, :created_at => creation)

    end

    (count*3).times do
      user = users[rand(users.size)]
      item = items[rand(items.size)]

      creation = self.time_rand([user.created_at, item.created_at].max)
      ret = self.time_rand(creation)
      Borrowing.create(:user => user, :item => item, :current => false, :created_at => creation, :returned_at => ret)

    end
  end

  def self.issues count
    borrows = Borrowing.all
    count.times do
      b = borrows[rand(borrows.size)]
      creation = self.time_rand(b.created_at)
      Issue.create(:borrowing => b, :created_at => creation)
    end
  end

  def self.tags count
    f = open('./script/tag_names.yml')
    tag_names = YAML::load(f)
    tag_names.each do |tag|
      Tag.create(:name => tag)
    end

    tags = Tag.all
    items = Item.all
    count.times do
      tag = tags[rand(tags.size)]
      item = items[rand(items.size)]
      item.tags << tag
      item.save
    end

  end

  def self.reviews count
    items = Item.all
    users = User.all
    count.times do
      user = users[rand(users.size)]
      item = items[rand(items.size)]

      creation = self.time_rand([user.created_at, item.created_at].max)

      Review.first_or_create({:user => user,
                    :item => item},{
                    :body => Faker::Lorem.paragraph(4),
                    :created_at => creation}) 
    end
  end

  def self.helpfuls count
    reviews = Review.all
    users = User.all

    count.times do
      user = users[rand(users.size)]
      review = reviews[rand(reviews.size)]

      h = Helpful.first_or_create({:review => review,
                               :user => user})
      
      h[:helpful] = rand() > 0.3 ? true : false
      if not h.save
        h.errors.each do |e|
          puts e
        end
      end
    end
  end

  def self.time_rand from = (DateTime.now - 100)
    from = Time.parse(from.to_s)
    Time.at(from + rand * (Time.now.to_f - from.to_f))
  end
end
