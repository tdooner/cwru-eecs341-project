require 'sinatra'
require 'slim'
require 'less'

get '/' do
	slim :index
end
