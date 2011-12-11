require 'faker'
require 'net/http'
require 'json'
require 'tempfile'

class Seed

	def self.run! count
		count = count.to_i
		self.communities
		self.users count
		self.items (count*4)
	end

	def self.communities
		Community.create(:name => 'Redmond, WA', :zip => 98052, :description => 'Micro$oft!')
		Community.create(:name => 'Pittsburgh, PA', :zip => 15217, :description => 'Pittsburgh Steelers')
		Community.create(:name => 'Bolingbrook, IL', :zip => 60490, :description => 'Bolingbrook User Groups')
		Community.create(:name => 'San Francisco, CA', :zip => 94108, :description => 'San Francisco is fun!')
		Community.create(:name => 'Macedonia, OH', :zip => 44056, :description => 'A nice place below Cleveland')
		Community.create(:name => 'Cleveland, OH', :zip => 44106, :description => 'Home of Case Western Reserve University')
	end

	def self.users count
		comms = Community.all
		count.times do
			comm = comms[rand(comms.size)]
			name = Faker::Name.name
			User.create!(:name => name,
				     :address => Faker::Address.street_address,
				     :city => comm.name,
				     :state => 'Ohio', #TODO: change this later
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
    
            name = item_names[rand(item_names.size)]
            f = self.get_image(name)

			a = Item.new(:value => rand(500),
				     :max_loan => 1 + rand(20),
				     :name => name,
				     :desc => Faker::Lorem.paragraph(5),
				     :user => user,
				     :image => f,
				     :created_at => self.time_rand(user.created_at))
			a.save
		end
	end

    def self.get_image(string)
        # Returns the top image in Google Image search for that string
        puts "Searching for " + string
        search_url = URI('http://ajax.googleapis.com/ajax/services/search/images')
        q = { :v => "1.0", :rsz => '8', :q => string }
        search_url.query = URI.encode_www_form(q)
        google_says = Net::HTTP.get_response(search_url)
        res = JSON.parse(google_says.read_body) 
        t = {}
        while (t.empty?)
            begin
                image_url = res["responseData"]["results"].sample["unescapedUrl"]
                f = Tempfile.new(string.gsub(/[^\w]*/,"")) 
                puts "Downloading " + image_url + "..."
                Net::HTTP.get_response(URI(image_url)) do |image|
                    f.write(image.body)
                end
                f.rewind
                t[:filename] = f.path.split("/")[-1]
                t[:type] = 'image/' + image_url.split('.')[-1]
                t[:name] = 'seed-image'
                t[:tempfile] = f
            end
        end

        t
    end



	def self.time_rand from = (DateTime.now - 100)
		from = Time.parse(from.to_s)
		Time.at(from + rand * (Time.now.to_f - from.to_f))
	end
end
