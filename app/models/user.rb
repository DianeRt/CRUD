class User < Sequel::Model

  def self.password(password=nil, salt=false)
    password_salt = salt ? salt : BCrypt::Engine.generate_salt
    password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    return password_salt, password_hash
  end

end