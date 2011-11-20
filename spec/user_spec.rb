require "#{File.dirname(__FILE__)}/spec_helper"

valid_user = {:name => "Tom", :address=>"1234 Street", :email => "tomdooner@gmail.com", :password => "pw", :password_repeat => "pw", :city => "Macedonia", :state => "OH", :zip => 12345}

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
end
