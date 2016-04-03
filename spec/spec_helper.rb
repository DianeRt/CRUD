ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'nokogiri'

Dir.glob('./app/{controllers}/*.rb').each { |file| require file }

include Rack::Test::Methods

DB.drop_table?(:users)
DB.create_table?(:users) do
  primary_key :id
  Boolean :admin
  String :fname
  String :lname
  String :email
  String :username
  String :password_hash
  String :password_salt
end

DB[:users].insert(admin: true, fname: "f1", lname: "l1", email: "e1", username: "u1")
DB[:users].insert(admin: false, fname: "f2", lname: "l2", email: "e2", username: "u2")