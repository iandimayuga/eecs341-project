require 'bcrypt'

class User
	include DataMapper::Resource
	include BCrypt
	attr_accessor :password, :password_repeat

	validates_presence_of :name, :address, :email, :city, :state, :zip
    validates_with_method :passwords_match
    validates_with_method :password_not_nil

	property :id, Serial
	property :name, String
	property :address, String
	property :city, String
	property :state, String
	property :zip, Integer
	property :email, String
	property :created_at, DateTime
	property :password_hash, BCryptHash
	property :is_admin, Boolean

	has n, :items
	has n, :borrowings
	has n, :items, :through => :borrowings
	belongs_to :community

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

end

