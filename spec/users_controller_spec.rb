require_relative 'spec_helper'

def app
  UsersController.new
end

describe UsersController do
  before do
    @users = DB[:users]
  end

  after do
    @users.truncate
  end
 
  #-------------------------------------------------------------------------------------
  describe "when logged in as an admin" do
    before do
      # DB.transaction(:rollback => :always) do
        @admin = User.create(admin: true, fname: "f1", lname: "l1", email: "e1", username: "u1")
        @user = User.create(fname: "different_user", lname: "l1")
        env "rack.session", {:current_user_id => @admin[:id]}
      # end
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
      # DB.transaction(:rollback => :always) do
        @regular_user = User.create(admin: false, fname: "f2", lname: "l2", email: "e2", username: "u2")
        @user = User.create(fname: "different_user", lname: "l2")
        env "rack.session", {:current_user_id => @regular_user[:id]}
      # end
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
      # DB.transaction(:rollback => :always) do
        post '/users', params = {fname: "f3", lname: "l3", email: "e3", username: "u3", password: "p3"}
        @user = User.first(fname: "f3")
      # end
    end

    # works with DB.transaction
    it "successfully creates a new user" do
      @user.wont_be_nil
    end

    it "successfully logs in a user" do
      post '/users/login', params = {username: "u3", password: "p3"}
      follow_redirect!
      path = last_request.fullpath
      path.must_equal "/users/#{@user[:id]}"
    end

    it "updates current_user info" do
      env "rack.session", {:current_user_id => @user[:id]}
      patch "/users/#{@user[:id]}", params = {fname: "FNAME", lname: "l3", email: "e3", username: "u3", password: "p3"}
      @user = User.first(id: @user[:id])
      @user[:fname].must_equal "FNAME"
    end

    # works with DB.transaction
    it "deletes current_user account" do
      current_user_id = @user[:id]
      delete "/users/#{current_user_id}"
      deleted_user = User.first(id: current_user_id)
      deleted_user.must_be_nil
    end
  end
end