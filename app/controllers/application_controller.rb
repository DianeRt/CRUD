require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'

Bundler.require(:default) 

class ApplicationController < Sinatra::Base
  enable :sessions
  enable :method_override
  register Sinatra::Flash
  set :views, File.expand_path('../../views', __FILE__)
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
      erb :"index"
    end
  end
end
