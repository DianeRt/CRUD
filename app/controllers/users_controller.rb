class UsersController < ApplicationController

  # Displays a new user form
  #-----------------------------------------------------------------
  get '/users/new/?' do
    erb :"new"
  end

  # Displays Home Page - Lists all the users in the database
  #-----------------------------------------------------------------
  get '/users/?' do
    authorize_user do
      @users = @users.order(:id).all
      erb :"index"
    end
  end

  # Displays specific users
  #-----------------------------------------------------------------
  get '/users/:id/?' do
    authorize_user(params[:id]) do
      @user = @users.where(id: params[:id]).first
      erb :"show"
    end
  end

  # Displays a user Edit Page
  #-----------------------------------------------------------------
  get '/users/:id/edit/?' do
    authorize_user(params[:id]) do
      @user = @users.where(id: params[:id]).first
      erb :"edit"
    end
  end

  # Login - Checks user credentials
  #-----------------------------------------------------------------
  post '/users/login/?' do
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
  post '/users/logout/?' do
    flash[:success] = "You have successfully logged out."
    @current_user = nil
    session[:current_user_id] = nil
    redirect '/homepage'
  end

  # Creates new user and saves it to database
  #-----------------------------------------------------------------
  post '/users/?' do
    password_salt = BCrypt::Engine.generate_salt
    password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)
    @users.insert(admin: false, fname: params[:fname], lname: params[:lname], email: params[:email], username: params[:username], password_salt: password_salt, password_hash: password_hash)
    if user_signed_in?
      flash[:success] = "Successfully added new user"
      redirect '/users'
    else
      flash[:succes] = "Successfully created new account"
      @user = @users.where(username: params[:username]).first
      session[:current_user_id] = @user[:id]
      redirect "/users/#{@user[:id]}"
    end
  end

  # Updates/Edits info of user
  #-----------------------------------------------------------------
  patch '/users/:id/?' do
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
  patch '/users/admin/:id/?' do
    @user = @users.where(id: params[:id])
    user_admin = !@user[:admin]
    @user.update(admin: user_admin)
    status = user_admin ? "assigned as admin" : "removed as admin"
    name = @user.first
    flash[:success] = "#{name[:fname].capitalize} #{name[:lname].capitalize} is #{status}"
    redirect "/users"
  end

  # Deletes User
  #-----------------------------------------------------------------
  delete '/users/:id/?' do
    name = @users.where(id: params[:id]).first
    @users.where(id: params[:id]).delete
    if current_user == nil
      flash[:success] = "Successfully deleted account"
      session[:current_user_id] = nil
      redirect '/homepage'
    else
      flash[:success] = "Successfully deleted #{name[:fname].capitalize} #{name[:lname].capitalize}"
      redirect '/users'
    end
  end

end