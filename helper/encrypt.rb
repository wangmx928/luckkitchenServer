require 'bcrypt'
class Secure
	def self.encrypt_bcrypt(text)
    	BCrypt::Password.create text
  	end
end