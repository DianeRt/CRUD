require_relative 'spec_helper'

def app
  UsersController.new
end

describe UsersController do
  before do
    @users = DB[:users]
  end
 
  #-------------------------------------------------------------------------------------
  describe "when logged in as an admin" do
    before do
      @admin = @users.where(admin: true).first
      env "rack.session", {:current_user_id => @admin[:id]}
    end

    it "able to access '/users' page" do
      get '/users'
      last_response.body.must_include "Complete CRUD Users"
    end

    it "able to access other user's page" do
      different_user_id = @admin[:id] + 1
      get "/users/#{different_user_id}"
      last_response.body.must_include "User Info"
    end

    it "displays all users '/users' page" do
      number_of_users = @users.count
      get '/users'
      users_page = Nokogiri::HTML(last_response.body)
      li_size = users_page.search("li").size
      li_size.must_equal number_of_users
    end
  end

  #-------------------------------------------------------------------------------------
  describe "when logged in as a regular user" do
    before do
      @regular_user = @users.where(admin: false).first
      env "rack.session", {:current_user_id => @regular_user[:id]}
    end

    it "can view own page" do
      get "/users/#{@regular_user[:id]}"
      last_response.body.must_include "User Info"
    end

    it "redirects regular_user when accessing '/users' page" do
      get '/users'
      follow_redirect!
      last_response.body.must_include "Unauthorized access"
    end

    it "redirects regular_user when accessing other user's page" do
      different_user_id = @regular_user[:id] + 1    
      get "/users/#{different_user_id}"
      follow_redirect!
      last_response.body.must_include "Unauthorized access"
    end
  end

  #-------------------------------------------------------------------------------------
  describe "testing login, create, update and delete" do
    before do
      post '/users', params = {fname: "f3", lname: "l3", email: "e3", username: "u3", password: "p3"}
      @current_user = @users.where(fname: "f3").first
    end

    it "successfully creates a new user" do
      @current_user.wont_be_nil
    end

    it "successfully logs in a user" do
      post '/users/login', params = {username: "u3", password: "p3"}
      follow_redirect!
      last_response.body.must_include "User Info"
    end

    it "updates current_user info" do
      env "rack.session", {:current_user_id => @current_user[:id]}
      patch "/users/#{@current_user[:id]}", params = {fname: "FNAME", lname: "l3", email: "e3", username: "u3", password: "p3"}
      follow_redirect!
      last_response.body.must_include "Successfully updated user info"
    end

    it "deletes current_user account" do
      current_user_id = @current_user[:id]
      delete "/users/#{current_user_id}"
      deleted_user = @users.where(id: current_user_id).first
      deleted_user.must_be_nil
    end
  end
end