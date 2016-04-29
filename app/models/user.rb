class User < Sequel::Model
  plugin :validation_helpers
  raise_on_save_failure = false

  def validate
    super
    validates_presence [:fname, :lname, :email, :username]
    validates_min_length 3, [:fname, :lname, :email, :username]
    validates_max_length 100, [:fname, :lname, :email, :username]
    validates_format /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, :email
    # validates_unique(:email, :username, [:fname, :lname]) # having trouble using this when updating info
  end

  def self.password(password=nil, salt=false)
    password_salt = salt ? salt : BCrypt::Engine.generate_salt
    password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    return password_salt, password_hash
  end

end