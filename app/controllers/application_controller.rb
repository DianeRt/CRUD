require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'

Bundler.require(:default) 

configure :test do
 set :database, 'postgresql://localhost/crud_test'
 DB = Sequel.connect("postgresql://localhost/crud_test")
end

configure :development do
  set :database, 'postgresql://localhost/crud_development'
  DB = Sequel.connect("postgresql://localhost/crud_development")
end

class ApplicationController < Sinatra::Base
  enable :sessions
  enable :method_override
  disable :show_exceptions   # disabled to hide NoMethodError. Display an error 500 page instead.
  register Sinatra::Flash
  set :views, proc { File.join(root, "..", "views") } 
  set :public_folder, proc { File.join(root, "../../") } # set public folder location relative to this file


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

  error 403 do
    erb :"error", locals: { error: "Access Forbidden"}
  end

  # Raises an error if admin goes to a '/users/:id' page that does not exist
  # Example: '/users/99' will not exist if there is no ID#99 in the database 
  error 500 do
    erb :"error", locals: { error: "Page does not exist"}
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
        403
      end
    else  
      403
    end
  end

  
  # redirects '/' route to '/users' route
  #-----------------------------------------------------------------
  get '/' do
    redirect '/homepage'
  end

  # Displays homepage for users to log in or sign up
  #-----------------------------------------------------------------
  get '/homepage/?' do
    if user_signed_in?
      flash[:error] = "Please log out to access homepage"
      redirect "/users/#{session[:current_user_id]}"
    else
      erb :"home"
    end
  end
end
