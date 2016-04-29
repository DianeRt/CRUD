require_relative 'spec_helper'

def app
  UsersController.new
end

describe UsersController do
  before do
    DatabaseCleaner.start
  end

  after do
    DatabaseCleaner.clean
  end
 
  #-------------------------------------------------------------------------------------
  describe "when logged in as an admin" do
    before do
        @admin = User.create(admin: true, fname: "ff1", lname: "ll1", email: "ee1@e1.com", username: "uu1")
        @user = User.create(fname: "different_user", lname: "ll1", email:"diff@diff.com", username: "diff1")
        env "rack.session", {:current_user_id => @admin[:id]}
    end

    it "able to access '/users' page" do
      get '/users'     
      last_response.status.must_equal 200
    end

    it "able to access other user's page" do
      get "/users/#{@user[:id]}"
      last_response.status.must_equal 200
    end

    it "displays all users '/users' page" do
      number_of_users = User.count
      get '/users'
      users_page = Nokogiri::HTML(last_response.body)
      li_size = users_page.search("li").size
      li_size.must_equal number_of_users
    end
  end

  #-------------------------------------------------------------------------------------
  describe "when logged in as a regular user" do
    before do
        @regular_user = User.create(admin: false, fname: "ff2", lname: "ll2", email: "ee2@e2.com", username: "uu2")
        @user = User.create(fname: "different_user", lname: "ll2", email:"diff@diff.com", username: "diff1")
        env "rack.session", {:current_user_id => @regular_user[:id]}
    end

    it "can view own page" do
      get "/users/#{@regular_user[:id]}"
      last_response.status.must_equal 200
    end

    it "shows 'Access forbidden' when accessing '/users' page" do
      get '/users'
      last_response.status.must_equal 403
    end

    it "shows 'Access forbidden' when accessing other user's page" do
      get "/users/#{@user[:id]}"
      last_response.status.must_equal 403
    end
  end

  # #-------------------------------------------------------------------------------------
  describe "testing login, create, update and delete" do
    before do
        post '/users', params = {fname: "ff3", lname: "ll3", email: "ee3@e3.com", username: "uu3", password: "p3"}
        @user = User.first(fname: "ff3")
    end

    it "successfully creates a new user" do
      @user.wont_be_nil
    end

    it "successfully logs in a user" do
      post '/users/login', params = {username: "uu3", password: "p3"}
      follow_redirect!
      path = last_request.fullpath
      path.must_equal "/users/#{@user[:id]}"
    end

    it "updates current_user info" do
      env "rack.session", {:current_user_id => @user[:id]}
      patch "/users/#{@user[:id]}", params = {fname: "FNAME", lname: "ll3", email: "ee3@e3.com", username: "uu3", password: "p3"}
      @user = User.first(id: @user[:id])
      @user[:fname].must_equal "FNAME"
    end

    it "deletes current_user account" do
      current_user_id = @user[:id]
      delete "/users/#{current_user_id}"
      deleted_user = User.first(id: current_user_id)
      deleted_user.must_be_nil
    end
  end
end