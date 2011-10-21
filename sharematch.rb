require 'sinatra'
require 'haml'
require 'less'
require 'sqlite3'


db = SQLite3::Database.new "./db/test.db"

before do
	@pills = Hash.new()
end

get '/' do
	@pills[:home] = 'active'
	haml :index
end

get '/find' do
	@pills[:find] = 'active'
	@users = db.execute( "select * from users" )
	haml :find
end

get '/share' do
	@pills[:share] = 'active'
	haml :share
end

get '/*.css' do
	less (:"style/#{params[:splat][0]}")
end

