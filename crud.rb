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
  redirect '/users'
end

# Displays a new user form (DONE)
#-----------------------------------------------------------------
get '/users/new' do
  erb :new_user
end

# Displays Home Page - Lists all the users in the database (DONE)
#-----------------------------------------------------------------
get '/users' do
  @users.all #<---- is this necessary? still works without it.
  erb :all_users
end

# Displays specific users (DONE)
#-----------------------------------------------------------------
get '/users/:id' do
  @users = @users.where(id: params[:id])
  # @users = @users.find(:id => params[:id]) #<--- using this only displays first data in DB
  erb :spec_user
end

# Dispalys a user Edit Page (DONE)
#-----------------------------------------------------------------
get '/users/:id/edit' do
  @users = @users.where(id: params[:id])
  erb :edit_user
end

# Creates new user and saves it to database (DONE)
#-----------------------------------------------------------------
post '/users' do
  @users.insert(fname: params[:fname], lname: params[:lname], email: params[:email])
  redirect '/users'
end

# Updates/Edits info of user (DONE)
#-----------------------------------------------------------------
patch '/users/:id' do
  @users = @users.where(id: params[:id])
  @users.update(fname: params[:fname], lname: params[:lname], email: params[:email])
  redirect '/users'
end

# Deletes User (DONE)
#-----------------------------------------------------------------
delete '/users/:id' do
  @users = @users.where(id: params[:id])
  @users.delete
  redirect '/users'
end