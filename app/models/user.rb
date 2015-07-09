class User < ActiveRecord::Base
	attr_accessor :remember_token, :activation_token, :password_reset_token
	before_save { :downcase_email }
  before_create {:create_activation}
	validates :name, presence: true, length: {maximum: 50}
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length: {maximum: 255}, format: {with: VALID_EMAIL_REGEX}, uniqueness: true
	has_secure_password	
	validates :password, presence: true, length: {minimum: 6}

	# Returns the hash digest of the given string.
	def self.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? Bcrypt::Engine::MIN_COST : BCrypt::Engine.cost
		 BCrypt::Password.create(string, cost: cost)
	end
	 # Returns a random token.
  def self.new_token
    SecureRandom.urlsafe_base64
  end
  def remember
  	self.remember_token = User.new_token
  	update_attribute(:remember_digest, User.digest(self.remember_token))
  end

  # Return true if the given token matches the digest.

  def authenticated?(attribute, token)
    digest = send "#{attribute}_digest"
    return false if digest.nil?
  	BCrypt::Password.new(digest).is_password?(token)
  end
  def password_reset_expired?
    self.reset_send_at < 2.hours.aqo
  end
  def reset?(user_params)
    update_attribute(user_params)
  end
  def activate
    self.update_attribute(:activated, true)
    self.update_attribute(:activated_at, Time.zone.now)
  end
  # Forgets user
  def forget
  	update_attribute(:remember_digest, nil)
  end
  def admin?
    self.admin
  end
  def send_email_activation_account
    UserMailer.account_activation(self).deliver_now
  end
  def send_email_password_reset
    create_reset_token
    UserMailer.password_reset(self).deliver_now
  end
  private

  def create_activation
    self.activation_token = User.new_token
    self.update_attribute(:activation_digest, User.digest(activation_token))
  end
  def downcase_email
    self.email = email.downcase 
  end
  def create_reset_token
    self.password_reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(password_reset_token))
    update_attribute(:reset_send_at, Time.zone.now)
  end
end
