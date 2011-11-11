require 'sinatra'
require 'haml'
require 'less'
require 'environment' # app/environment.rb



module ShareMatch
	class App < Sinatra::Base
		dir = File.dirname(File.expand_path(__FILE__))
		set :root,     "#{dir}/.."
		set :public_folder,   "#{dir}/../public"
		set :app_file, __FILE__
		set :views,    "app/views"
		enable :sessions
		set :session_secret, "My session secret"#debug only, to work with shotgun


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

			@items = Item.all

			haml :find
		end

		get '/share' do
			login_required
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

		post '/sign-up' do
			if params[:step] == "1"
				params.delete("step")
				@a = User.new(params)
				if @a.valid?
					@a.save
					session[:user] = @a.id
					redirect '/sign-up?step=2'
				else
					redirect '/sign-up'
				end
			end
			return params.inspect
		end

		get '/login' do
			@nav[:user] = 'active'
			@pills[:login] = 'active'
			haml :login
		end

		post '/login' do
			if user = User.authenticate(params[:email], params[:password])
				session[:user] = user.id
				redirect '/login'#TODO: make this redirect to the incoming page!
			else
				redirect '/login'
			end
		end

		get '/logout' do
			session[:user] = nil
			redirect '/'
		end

		get '/you' do #TODO: This shit is making Roy Fielding angry.  You won't like him when he's angry. 
			@nav[:user] = 'active'
			haml :user
		end

		get '/*.css' do
			#TODO: make these served up directly to browser and interpreted there
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

			def login_required
				if session[:user]
					return true
				else
					return redirect '/login'
				end
			end

			def current_user
				User.get(session[:user])
			end

                        def admin_required
                                if session[:user] and User.get(session[:user]).is_admin?
                                        return true
                                else
                                        return redirect '/login'
                                end
                        end

                        def include_styles
                                styles = Dir.glob("public/styles/*.less").map{|path| path.slice!("public") ; path }
                                out = ""
                                styles.each{ |file| out << "%link{:rel=>\"stylesheet/less\",:type=>\"text/css\",:href=>\"#{file}\"}\n" }
                                haml out
                        end

                        def include_scripts
                                scripts = Dir.glob("public/scripts/*.js").map{|path| path.slice!("public") ; path }
                                out = ""
                                scripts.each{ |file| out << "%script{:src=>\"#{file}\",:type=>\"text/javascript\"}\n" }
                                haml out
                        end
		end
	end
end
