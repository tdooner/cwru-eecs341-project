require "#{File.dirname(__FILE__)}/spec_helper"

describe 'user' do
    it "returns a valid instance when given form inputs" do
        User.new(Fixtures::VALID_USER).valid?.should eq(true)
    end
    it "should be invalid if passwords are empty" do
        invalid_user = Fixtures::VALID_USER.dup
        invalid_user[:password] = ""
        invalid_user[:password_repeat] = ""
        User.new( invalid_user ).valid?.should eq(false)
    end
    it "should be invalid if passwords don't match" do
        invalid_user = Fixtures::VALID_USER.dup
        invalid_user[:password_repeat] = "testone"
        User.new( invalid_user ).valid?.should eq(false)
    end
    it "should be invalid with no email" do
        User.new( Fixtures::VALID_USER.reject{|k,v| k == :email} ).valid?.should eq(false)
    end
    it "should be invalid without a name" do
        invalid_user = Fixtures::VALID_USER.dup
        invalid_user[:name] = ""
        User.new( invalid_user ).valid?.should eq(false)
    end
    it "should be invalid without a street address" do
        invalid_user = Fixtures::VALID_USER.dup
        invalid_user[:address] = ""
        User.new( invalid_user ).valid?.should eq(false)
        invalid_user = Fixtures::VALID_USER.dup
        invalid_user[:city] = ""
        User.new( invalid_user ).valid?.should eq(false)
        invalid_user = Fixtures::VALID_USER.dup
        invalid_user[:state] = ""
        User.new( invalid_user ).valid?.should eq(false)
        invalid_user = Fixtures::VALID_USER.dup
        invalid_user[:zip] = nil
        User.new( invalid_user ).valid?.should eq(false)
    end
    it "should save successfully to the database" do
        u = User.new(Fixtures::VALID_USER)
        u.should be_instance_of(User)
        r = u.save()
        r.should eq(true)
        u2 = User.get(u.id)
        u2.should be_instance_of(User)
        u2.id.should eq(u.id)
    end
    it "saves updates to an existing user with new password" do
        u = User.new(Fixtures::VALID_USER)
        u.save().should eq(true)
        u = User.get(u.id)
        u.update(Fixtures::VALID_USER2).should eq(true)
        u.name.should eq(Fixtures::VALID_USER2[:name])
    end
    it "saves updates to an existing user without changing password" do
        u = User.new(Fixtures::VALID_USER)
        u.save().should eq(true)
        u = User.get(u.id)
        valid_user2 = Fixtures::VALID_USER2.dup.reject{|k,v| k == :password or k == :password_repeat}
        u.update(valid_user2).should eq(true)
        u.name.should eq(valid_user2[:name])
    end
    it "allows joining of a community after user creation" do
        u = User.new(Fixtures::VALID_USER)   # Create the user first
        u.save().should eq(true)
        u2 = User.get(u.id)        # Then load it and have it join
        u2.location_id = 1         #  the community
        u2.save().should eq(true)
    end
end
describe 'The sign-up process', :type => :request do
    it 'allows creation of a user' do
        signup_page_one(Fixtures::VALID_USER)
        find("div.container h6").should have_content("step 2 of 3")
    end
    it 'shows your name on top after the first step (logs you in)' do
        signup_page_one(Fixtures::VALID_USER)
        find(".pills").should have_content(Fixtures::VALID_USER[:name])
    end
    it "doesn't show your name on top on the first step" do
        visit '/sign-up'
        body.should_not have_content("Log Out")
        body.should have_content("Sign Up")
        body.should have_content("Log In")
    end
    it 'allows you to create a community' do
        signup_page_one(Fixtures::VALID_USER)
        fill_in 'name', :with=>Fixtures::VALID_COMMUNITY[:name]
        fill_in 'zip_code', :with=>Fixtures::VALID_COMMUNITY[:zip_code]
        click_button 'Create and Join'
        find("div.container h6").should have_content("step 3 of 3")
        body.should_not have_content("Error:")
    end
end
describe 'User edit page', :type => :request do
    it 'shows you a page of your own information' do
        signup_page_one(Fixtures::VALID_USER)
        click_link Fixtures::VALID_USER[:name]
        current_path.should match(/\/users\/[0-9]+\/edit/)
        find_field("name").value.should eq(Fixtures::VALID_USER[:name])
        find_field("email").value.should eq(Fixtures::VALID_USER[:email])
        find_field("address").value.should eq(Fixtures::VALID_USER[:address])
        find_field("city").value.should eq(Fixtures::VALID_USER[:city])
        find_field("zip").value.to_i.should eq(Fixtures::VALID_USER[:zip].to_i)
    end
end
describe 'the login process', :type => :request do
    before :each do
        User.create(Fixtures::VALID_USER).should be_instance_of(User)
    end

    it 'logs in a user correctly' do
        login(Fixtures::VALID_USER)
        current_path.should_not eq('/login')
    end

    it 'fails with an incorrect password' do
        visit '/login'
        fill_in "uname", :with => Fixtures::VALID_USER[:email]
        fill_in "password", :with => Fixtures::VALID_USER[:password].reverse
        click_button 'Login'
        current_path.should eq('/login')
        body.should have_content("Uh oh")
    end

    it 'fails with an incorrect username' do
        visit '/login'
        fill_in "uname", :with => Fixtures::VALID_USER[:email].reverse
        fill_in "password", :with => Fixtures::VALID_USER[:password]
        click_button 'Login'
        current_path.should eq('/login')
        body.should have_content("Uh oh")
    end
end
