require 'minitest/autorun'
require 'sqlite3'


class TestUser < MiniTest::Unit::TestCase
	
	def setup
		db = SQLite3::Database.new "./db/test.db"
		@users = db.execute( "select name from users" )
	end

	def test_name
		assert_equal "Brian Stack", @users[0][0]
	end
end
