class User < ActiveRecord::Base
  ### APPSEC Vuln 11: Plaintext password storage (has_secure_password is commented out)
  has_secure_password
  after_create :generate_token

  def generate_token
    self.token = SecureRandom.hex
    self.save
  end
end