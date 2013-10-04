class User < ActiveRecord::Base
	has_secure_password

  attr_accessible :account, :class_id, :password, :password_confirmation
	
	validates_uniqueness_of :account
end
