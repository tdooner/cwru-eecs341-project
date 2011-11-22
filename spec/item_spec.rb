require "#{File.dirname(__FILE__)}/spec_helper"

describe 'item', :type => :request do
    it 'allows creation of a valid item if you are logged in' do
        signup_page_one(Fixtures::VALID_USER)
        visit '/item/new'
        fill_in 'name', :with => Fixtures::VALID_ITEM[:name]
        fill_in 'value', :with => Fixtures::VALID_ITEM[:value]
        fill_in 'max_loan', :with => Fixtures::VALID_ITEM[:max_loan]
        fill_in 'desc', :with => Fixtures::VALID_ITEM[:desc]
        click_button 'Share it!'
        current_path.should_not eq('/item/new')
        body.should_not have_content("That item is not valid!")
    end
end
