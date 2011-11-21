require "#{File.dirname(__FILE__)}/spec_helper"

valid_user = {:name => "Tom", :address=>"1234 Street", :email => "tomdooner@gmail.com", :password => "pw", :password_repeat => "pw", :city => "Macedonia", :state => "OHIO!", :zip => 12345}
valid_user2 = {:name => "Brian", :address=>"1234 Brian Stack Ave.", :email => "bis12@case.edu", :password => "password", :password_repeat => "password", :city => "Pittsburgh", :state => "PA", :zip => 45678}
valid_community = {:name => "place one", :zip_code=>12345}
valid_community2 = {:name => "place two", :zip_code=>23456}

describe 'user' do
    it "returns a valid instance when given form inputs" do
        User.new(valid_user).valid?.should eq(true)
    end
    it "should be invalid if passwords are empty" do
        invalid_user = valid_user.dup
        invalid_user[:password] = ""
        invalid_user[:password_repeat] = ""
        User.new( invalid_user ).valid?.should eq(false)
    end
    it "should be invalid if passwords don't match" do
        invalid_user = valid_user.dup
        invalid_user[:password_repeat] = "testone"
        User.new( invalid_user ).valid?.should eq(false)
    end
    it "should be invalid with no email" do
        User.new( valid_user.reject{|k,v| k == :email} ).valid?.should eq(false)
    end
    it "should be invalid without a name" do
        invalid_user = valid_user.dup
        invalid_user[:name] = ""
        User.new( invalid_user ).valid?.should eq(false)
    end
    it "should be invalid without a street address" do
        invalid_user = valid_user.dup
        invalid_user[:address] = ""
        User.new( invalid_user ).valid?.should eq(false)
        invalid_user = valid_user.dup
        invalid_user[:city] = ""
        User.new( invalid_user ).valid?.should eq(false)
        invalid_user = valid_user.dup
        invalid_user[:state] = ""
        User.new( invalid_user ).valid?.should eq(false)
    end
    it "should save successfully to the database" do
        u = User.new(valid_user)
        u.should be_instance_of(User)
        r = u.save()
        r.should eq(true)
        u2 = User.get(u.id)
        u2.should be_instance_of(User)
        u2.id.should eq(u.id)
    end
    it "saves updates to an existing user with new password" do
        u = User.new(valid_user)
        u.save().should eq(true)
        u = User.get(u.id)
        u.update(valid_user2).should eq(true)
        u.name.should eq(valid_user2[:name])
    end
    it "saves updates to an existing user without changing password" do
        u = User.new(valid_user)
        u.save().should eq(true)
        u = User.get(u.id)
        valid_user2 = valid_user2.dup.reject{|k,v| k == :password or k == :password_repeat}
        u.update(valid_user2).should eq(true)
        u.name.should eq(valid_user2[:name])
    end
    it "allows joining of a community after user creation" do
        u = User.new(valid_user)   # Create the user first
        u.save().should eq(true)
        u2 = User.get(u.id)        # Then load it and have it join
        u2.location_id = 1         #  the community
        u2.save().should eq(true)
    end
end
describe 'The sign-up process', :type => :request do
    it 'allows creation of a user' do
        signup_page_one(valid_user)
        find("div.container h6").should have_content("step 2 of 3")
    end
    it 'shows your name on top after the first step (logs you in)' do
        signup_page_one(valid_user)
        find(".pills").should have_content(valid_user[:name])
    end
    it 'allows you to create a community' do
        signup_page_one(valid_user)
        fill_in 'name', :with=>valid_community[:name]
        fill_in 'zip_code', :with=>valid_community[:zip_code]
        click_button 'Create and Join'
        find("div.container h6").should have_content("step 3 of 3")
        body.should_not have_content("Error: Could not join community!")
    end
end
describe 'User edit page', :type => :request do
    it 'shows you a page of your own information' do
        signup_page_one(valid_user)
        click_link valid_user[:name]
        current_path.should match(/\/users\/[0-9]+\/edit/)
        find_field("name").value.should eq(valid_user[:name])
        find_field("email").value.should eq(valid_user[:email])
        find_field("address").value.should eq(valid_user[:address])
        find_field("city").value.should eq(valid_user[:city])
        find_field("zip").value.to_i.should eq(valid_user[:zip].to_i)
    end
end
describe 'the login process', :type => :request do
    before :each do
        User.create(valid_user).should be_instance_of(User)
    end

    it 'logs in a user correctly' do
        login(valid_user)
        current_path.should_not eq('/login')
    end

    it 'fails with an incorrect password' do
        visit '/login'
        fill_in "uname", :with => valid_user[:email]
        fill_in "password", :with => valid_user[:password].reverse
        click_button 'Login'
        current_path.should eq('/login')
        body.should have_content("Uh oh")
    end

    it 'fails with an incorrect username' do
        visit '/login'
        fill_in "uname", :with => valid_user[:email].reverse
        fill_in "password", :with => valid_user[:password]
        click_button 'Login'
        current_path.should eq('/login')
        body.should have_content("Uh oh")
    end
end
