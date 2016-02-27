require 'sinatra'
require 'sequel'

DB = Sequel.connect("postgresql://localhost/users")

DB.create_table :users do
  primary_key :id
  String :fname
  String :lname
  String :email
end