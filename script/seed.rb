require 'faker'

class Seed

	def self.run! count
		count = count.to_i
		self.communities
		self.users count
		self.items (count*4)
	end

	def self.communities
		#Create Pittsburgh
		Community.create(:name => 'Macedonia', :zip => 44056, :description => 'A nice place below Cleveland')
		#Create Cleveland
		Community.create(:name => 'Cleveland', :zip => 44106, :description => 'Home of Case Western Reserve University')
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

			f = {}
			path = images[rand(images.size)]
			f[:filename] = path.split('/')[-1]
			f[:type] = 'image/' + path.split('.')[-1]
			f[:name] = 'seed-image'
			f[:tempfile] = File.open("script/images/3.jpg")
			f[:head] = "Content-Disposition: form-data; name=\"image\"; filename=\"icon.png\"\r\nContent-Type: image/png\r\n"


			a = Item.new(:value => rand(500) +rand,
				     :max_loan => 1 + rand(20),
				     :name => item_names[rand(item_names.size)],
				     :desc => Faker::Lorem.paragraph(5),
				     :user => user,
				     :image => f,
				     :created_at => self.time_rand(user.created_at))
			a.save!
		end
	end


	def self.time_rand from = (DateTime.now - 100)
		from = Time.parse(from.to_s)
		Time.at(from + rand * (Time.now.to_f - from.to_f))
	end
end
