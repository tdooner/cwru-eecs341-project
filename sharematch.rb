require 'sinatra'
require 'slim'
require 'less'
require 'sqlite3'


db = SQLite3::Database.new "./db/test.db"

before do
	@pills = Hash.new()
end

get '/' do
	@pills[:home] = 'active'
	slim :index
end

get '/find' do
	@pills[:find] = 'active'
	@items = db.execute( "select * from test" )
	slim :find
end

get '/share' do
	@pills[:share] = 'active'
	slim :share
end

get '/*.css' do
	less (:"style/#{params[:splat][0]}")
end

