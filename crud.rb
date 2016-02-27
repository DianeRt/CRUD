require 'sinatra'
require 'sequel'

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

# DUPLICATE Displays a new user form (DONE)
#-----------------------------------------------------------------
get '/users/new5' do
  erb :new_user2
end

# Displays Home Page - Lists all the users in the database (DONE)
#-----------------------------------------------------------------
get '/users' do
  @users.all
  erb :all_users
end

# Displays specific users (DONE)
#-----------------------------------------------------------------
get '/users/:id' do
  @users = @users.where(id: params[:id])
  # @users = @users.find params[:id] #<--- did not work before because it was written as find(params[:id])
  # @users = @users.find(:id => params[:id]) #<--- using this only displays first data in DB
  erb :spec_user
end

# Dispalys a user Edit Page (DONE)
#-----------------------------------------------------------------
get '/users/:id/edit' do
  @users = @users.where(id: params[:id])
  # @users = @users.find params[:id]
  erb :edit_user
end

# Creates new user and saves it to database (DONE)
#-----------------------------------------------------------------
post '/users' do
  @users.insert(fname: params[:fname], lname: params[:lname], email: params[:email])
  redirect '/users'
end

# Updates/Edits info of user
#-----------------------------------------------------------------
patch '/users/:id' do
  # id = params[:id]
  # @users = @users.where(id: id)
  @users = @users.where(id: params[:id])
  # @users = @users.find params[:id]
  # @users = @users[id: params[:id]]
  # @users.where(id: params[:id]).update(params[:users])
  # @users.update_attributes(fname: params[:fname], lname: params[:lname], email: params[:email])
  @users.update(fname: params[:fname], lname: params[:lname], email: params[:email]) #<--- this works  @user.update params
  # DB[:users].where(id: params[:id].to_i)
  # @users.update(params[:users])
  redirect '/users'
end

# Deletes User (DONE)
#-----------------------------------------------------------------
delete '/users/:id' do
  @users = @users.where(id: params[:id])
  @users.delete
  redirect '/users'
end


























