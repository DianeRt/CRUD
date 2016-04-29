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
      @users = User.order(:id).all
      erb :"index"
    end
  end

  # Displays specific users
  #-----------------------------------------------------------------
  get '/users/:id/?' do
    authorize_user(params[:id]) do
      @user = User.first(id: params[:id])
      erb :"show"
    end
  end

  # Displays a user Edit Page
  #-----------------------------------------------------------------
  get '/users/:id/edit/?' do
    authorize_user(params[:id]) do
      @user = User.first(id: params[:id])
      erb :"edit"
    end
  end

  # Login - Checks user credentials
  #-----------------------------------------------------------------
  post '/users/login/?' do
    @user = User.first(username: params[:username])
    if @user == nil
      flash[:error] = "Wrong username or password"
      redirect back
    else
      password_salt, password_hash = User.password(params[:password], @user[:password_salt])
      if @user[:password_hash] == password_hash
        session[:current_user_id] = @user[:id]
        redirect "/users/#{@user[:id]}"
      else
        flash[:error] = "Wrong username or password"
        redirect back
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
    password_salt, password_hash = User.password(params[:password])
    @user = User.new(admin: false, fname: params[:fname], lname: params[:lname], email: params[:email], username: params[:username], password_salt: password_salt, password_hash: password_hash)
    @user.valid?
    if @user.errors.count == 0
      @user.save
      if user_signed_in?
        flash[:success] = "Successfully added new user"
        redirect '/users'
      else
        flash[:succes] = "Successfully created new account"
        session[:current_user_id] = @user[:id]
        redirect "/users/#{@user[:id]}"
      end
    else
      flash[:error] = @user.errors
      redirect back
    end
  end

  # Updates/Edits info of user
  #-----------------------------------------------------------------
  patch '/users/:id/?' do
    password_salt, password_hash = User.password(params[:password])
    @user = User.new(fname: params[:fname], lname: params[:lname], email: params[:email], username: params[:username], password_salt: password_salt, password_hash: password_hash)
    @user.valid?
    if @user.errors.count == 0
      User.first(id: params[:id]).update(fname: params[:fname], lname: params[:lname], email: params[:email], username: params[:username], password_salt: password_salt, password_hash: password_hash)
      @user = current_user
      flash[:success] = "Successfully updated user info"
      redirect "/users/#{@user[:id]}"
    else
      flash[:error] = @user.errors
      redirect back
    end
  end

  # Updates/Changes the admin status of user
  #-----------------------------------------------------------------
  patch '/users/admin/:id/?' do
    @user = User.first(id: params[:id])
    user_admin = !@user[:admin]
    @user.update(admin: user_admin)
    status = user_admin ? "assigned as admin" : "removed as admin"
    flash[:success] = "#{@user[:fname].capitalize} #{@user[:lname].capitalize} is #{status}"
    redirect "/users"
  end

  # Deletes User
  #-----------------------------------------------------------------
  delete '/users/:id/?' do
    name = User.first(id: params[:id])
    User[params[:id]].delete
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