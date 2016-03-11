require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'

Bundler.require(:default) 

class Crud < Sinatra::Base
  enable :sessions
  enable :method_override
  register Sinatra::Flash

  DB = Sequel.connect("postgresql://localhost/users")

  # create @users variable to give access to view files
  #-----------------------------------------------------------------
  def initialize
    super
    @users = DB[:users] #=> Sequel::Dataset
  end

  def user_signed_in?
    !!session[:current_user_id]
  end

  def current_user
    @current_user ||= @users.where(id: session[:current_user_id]).first
  end

  def authorize_user(params=nil)
    unless block_given?
      raise "block must be provided"
    end

    if user_signed_in?
      if current_user[:admin] == true
        yield
      elsif params.to_s == session[:current_user_id].to_s
        yield
      else
        flash[:error] = "Unauthorized access"
        redirect "/users/#{session[:current_user_id]}"
      end
    else  
      flash[:error] = "Unauthorized access"
      redirect '/homepage'
    end
  end

  # redirects '/' route to '/users' route (DONE)
  #-----------------------------------------------------------------
  get '/' do
    redirect '/homepage'
  end

  # Displays homepage for users to log in or sign up
  #-----------------------------------------------------------------
  get '/homepage' do
    if user_signed_in?
      flash[:error] = "Please log out to access homepage"
      redirect "/users/#{session[:current_user_id]}"
    else
      erb :"homepage/index"
    end
  end

  # Displays a new user form (DONE)
  #-----------------------------------------------------------------
  get '/users/new' do
    erb :"users/new"
  end

  # Displays Home Page - Lists all the users in the database (DONE)
  #-----------------------------------------------------------------
  get '/users' do
    authorize_user do
      @users = @users.order(:id).all
      erb :"users/index"
    end
  end

  # Displays specific users (DONE)
  #-----------------------------------------------------------------
  get '/users/:id' do
    authorize_user(params[:id]) do
      @user = @users.where(id: params[:id]).first
      erb :"users/show"
    end
  end

  # Displays a user Edit Page (DONE)
  #-----------------------------------------------------------------
  get '/users/:id/edit' do
    authorize_user(params[:id]) do
      @user = current_user
      erb :"users/edit"
    end
  end

  # Login - Checks user credentials
  #-----------------------------------------------------------------
  post '/users/login' do
    @user = @users.where(username: params[:username]).first
    if @user == nil
      flash[:error] = "Wrong username or password"
      redirect '/homepage'
    else
      password = BCrypt::Engine.hash_secret(params[:password], @user[:password_salt])
      if @user[:password_hash] == password
        session[:current_user_id] = @user[:id]
        redirect "/users/#{@user[:id]}"
      else
        flash[:error] = "Wrong username or password"
        redirect '/homepage'
      end
    end
  end

  # Logs out user
  #-----------------------------------------------------------------
  post '/users/logout' do
    flash[:success] = "You have successfully logged out."
    @current_user = nil
    session[:current_user_id] = nil
    redirect '/homepage'
  end

  # Creates new user and saves it to database (DONE)
  #-----------------------------------------------------------------
  post '/users' do
    password_salt = BCrypt::Engine.generate_salt
    password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)
    @users.insert(admin: false, fname: params[:fname], lname: params[:lname], email: params[:email], username: params[:username], password_salt: password_salt, password_hash: password_hash)
    flash[:success] = "Successfully added new user"
    @user = @users.where(username: params[:username]).first
    session[:current_user_id] = @user[:id]
    redirect "/users/#{@user[:id]}"
  end

  # Updates/Edits info of user (DONE)
  #-----------------------------------------------------------------
  patch '/users/:id' do
    @user = @users.where(id: params[:id])
    password_salt = BCrypt::Engine.generate_salt
    password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)
    @user.update(fname: params[:fname], lname: params[:lname], email: params[:email], username: params[:username], password_salt: password_salt, password_hash: password_hash)
    @user = current_user
    flash[:success] = "Successfully updated user info"
    redirect "/users/#{@user[:id]}"
  end

  # Updates/Changes the admin status of user
  #-----------------------------------------------------------------
  patch '/users/admin/:id' do
    @user = @users.where(id: params[:id])
    user_admin = !@user[:admin]
    @user.update(admin: user_admin)
    status = user_admin ? "assigned as admin" : "removed as admin"
    name = @user.first
    flash[:success] = "#{name[:fname].capitalize} #{name[:lname].capitalize} is #{status}"
    redirect "/users"
  end

  # Deletes User (DONE)
  #-----------------------------------------------------------------
  delete '/users/:id' do
    @user = @users.where(id: params[:id]).delete
    redirect '/users'
  end

  run!
end
