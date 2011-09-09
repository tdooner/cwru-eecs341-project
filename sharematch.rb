require 'sinatra'
require 'slim'

get '/' do
	slim :index
end

__END__

@@layout
doctype html
html
  head
    meta charset="utf-8"
    title Share*Match
    link rel="stylesheet" 
  body
    h1 Share*Match
    == yield

@@index
h2 This is thin! Running with Shotgun!
