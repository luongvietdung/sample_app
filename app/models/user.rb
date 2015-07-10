class User < ActiveRecord::Base
	attr_accessor :remember_token
	before_save { self.email = email.downcase }
	validates :name, presence: true, length: {maximum: 50}
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length: {maximum: 255}, format: {with: VALID_EMAIL_REGEX}, uniqueness: true
	has_secure_password	
	validates :password, presence: true, length: {minimum: 6}

	def remember
		self.remember_token = User.new_token
		self.remember_digest = User.encrypt(self.remember_token)
		update_attribute(:remember_digest, self.remember_digest)
	end

	def forgot
		self.remember_token = nil
		update_attribute(:remember_digest, nil	)
	end

	def authenticated?(token)
		return false if token.nil?
		BCrypt::Password.new(self.remember_digest) == token
	end

	private

		def User.new_token
			SecureRandom.urlsafe_base64
		end

		def User.encrypt(token)
			cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
	    	BCrypt::Password.create(token, cost: cost)
		end
end
