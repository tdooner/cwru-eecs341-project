require 'sinatra'
require 'slim'

layout 'layout'

get '/' do
  slim :index
end
