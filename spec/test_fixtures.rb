module Fixtures
    VALID_USER = {
        :name => "Tom", 
        :address=>"1234 Street", 
        :email => "tomdooner@gmail.com", 
        :password => "pw", 
        :password_repeat => "pw", 
        :city => "Macedonia", 
        :state => "OHIO!", 
        :zip => 12345
    }
    VALID_USER2 = {
        :name => "Brian", 
        :address=>"1234 Brian Stack Ave.",
        :email => "bis12@case.edu",
        :password => "password",
        :password_repeat => "password",
        :city => "Pittsburgh",
        :state => "PA",
        :zip => 45678
    }
    VALID_COMMUNITY = {:name => "place one", :zip_code=>12345}
    VALID_COMMUNITY2 = {:name => "place two", :zip_code=>23456}
    VALID_ITEM = {:name => "Frying Pan", :value => 99.99, :max_loan => 20, :desc => ""}
end