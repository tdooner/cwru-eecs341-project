require 'sinatra'
require 'haml'
require 'less'
require 'sqlite3'


module ShareMatch
	class App < Sinatra::Base
		dir = File.dirname(File.expand_path(__FILE__))
		set :root,     "#{dir}/.."
		set :public_folder,   "#{dir}/../public"
		set :app_file, __FILE__
		set :views,    "app/views"


		before do
			@nav = Hash.new()
			@pills = Hash.new()
		end

		get '/' do
			@nav[:home] = 'active'
			haml :index
		end

		get '/find' do
			@nav[:find] = 'active'
			haml :find
		end

		get '/share' do
			@nav[:share] = 'active'
			haml :share
		end

		get '/search' do
			@nav[:search] = 'active'
			haml :search
		end

		get '/sign-up' do
			@nav[:user] = 'active'
			@pills[:signup] = 'active'

			@step = 1
			@step = params[:step] if params[:step]
			@part = "signup/_step#{@step}"
    
            @user = User.new
			haml :'signup/signup'
		end

		get '/login' do
			@nav[:user] = 'active'
			@pills[:login] = 'active'
			haml :login
		end

		get '/you' do
			@nav[:user] = 'active'
			haml :user
		end

		get '/*.css' do
			less (:"style/#{params[:splat][0]}")
		end

		helpers do 
			def signup_crumbs text, id, step
				retr = '<li'
				if  id == Integer(step)
					retr << ' class="active">'
					retr << text
				else
					retr << '>'
					retr << "<a href=\"/sign-up?step=#{id}\">"
					retr << text
				        retr << '</a></li>'
				end
				return retr
			end

			def nav_li text, link, key
				el = "%li{:class=>\"#{key}\"}\n  %a{:href=>\"#{link}\"}#{text}
				"
				haml el
			end
		end
	end
end
