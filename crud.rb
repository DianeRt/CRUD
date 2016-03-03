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

# Displays a log in page
#-----------------------------------------------------------------
get '/users/login' do
  erb :"homepage/login"
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

# Creates new user and saves it to database (DONE)
#-----------------------------------------------------------------
post '/users' do
  @users.insert(fname: params[:fname], lname: params[:lname], email: params[:email], username: params[:username], password: params[:password])
  redirect '/users'
end

# Updates/Edits info of user (DONE)
#-----------------------------------------------------------------
patch '/users/:id' do
  @user = @users.where(id: params[:id])
  @user.update(fname: params[:fname], lname: params[:lname], email: params[:email])
  redirect '/users'
end

# Deletes User (DONE)
#-----------------------------------------------------------------
delete '/users/:id' do
  @user = @users.where(id: params[:id]).delete
  redirect '/users'
end