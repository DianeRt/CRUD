require 'rubygems'
require 'bundler/setup'

Bundler.require(:default) 

DB = Sequel.connect("postgresql://localhost/users")


# create @users variable to give access to view files
# do i have to create an initialize method?
#-----------------------------------------------------------------
def initialize
  @users = DB[:users]
end

# redirects '/' route to '/users' route (DONE)
#-----------------------------------------------------------------
get '/' do
  redirect '/homepage'
end

# Displays homepage for users to log in or sign up
#-----------------------------------------------------------------
get '/homepage' do
  erb :"homepage/index"
end

# Logs out user
#-----------------------------------------------------------------
get '/users/logout' do
  @user = nil
  @users = DB[:users]
  redirect '/homepage'
end

# Displays a new user form (DONE)
#-----------------------------------------------------------------
get '/users/new' do
  erb :"users/new"
end

# Displays Home Page - Lists all the users in the database (DONE)
#-----------------------------------------------------------------
get '/users' do
  @users.all #<---- is this necessary? still works without it.
  erb :"users/index"
end

# Displays specific users (DONE)
#-----------------------------------------------------------------
get '/users/:id' do
  @user = @users.where(id: params[:id]).first
  # @users = @users.find(:id => params[:id]) #<--- using this only displays first data in DB
  erb :"users/show"
end

# Dispalys a user Edit Page (DONE)
#-----------------------------------------------------------------
get '/users/:id/edit' do
  @user = @users.where(id: params[:id]).first
  erb :"users/edit"
end

# Login - Checks user credentials
#-----------------------------------------------------------------
post '/users/login' do
  @user = @users.where(username: params[:username]).first
  if @user == nil
    erb :"homepage/error"
  else
    # password_salt = @user[:password_salt]
    password = BCrypt::Engine.hash_secret(params[:password], @user[:password_salt])
    if @user[:password_hash] == password
      erb :"users/show"
    else
      erb :"homepage/error"
    end
  end
end

# Creates new user and saves it to database (DONE)
#-----------------------------------------------------------------
post '/users' do
  password_salt = BCrypt::Engine.generate_salt
  password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)
  @users.insert(fname: params[:fname], lname: params[:lname], email: params[:email], username: params[:username], password_salt: password_salt, password_hash: password_hash)
  @user = @users.where(username: params[:username]).first
  erb :"users/show"
end

# Updates/Edits info of user (DONE)
#-----------------------------------------------------------------
patch '/users/:id' do
  @user = @users.where(id: params[:id])
  password_salt = BCrypt::Engine.generate_salt
  password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)
  @user.update(fname: params[:fname], lname: params[:lname], email: params[:email], username: params[:username], password_salt: password_salt, password_hash: password_hash)
  @user = @users.where(username: params[:username]).first
  erb :"users/show"
end

# Deletes User (DONE)
#-----------------------------------------------------------------
delete '/users/:id' do
  @user = @users.where(id: params[:id]).delete
  redirect '/users'
end