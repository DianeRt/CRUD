require 'sinatra'
require 'sequel'

DB = Sequel.connect("postgresql://localhost/users")

DB.create_table :users do
  primary_key :id
  Boolean :admin
  String :fname
  String :lname
  String :email
  String :username
  String :password_hash
  String :password_salt
end