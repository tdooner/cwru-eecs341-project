require 'sinatra'
require 'haml'
require 'less'
require 'rack-flash'
require 'padrino-mailer'
require 'environment' # app/environment.rb



module ShareMatch
	class App < Sinatra::Base
		dir = File.dirname(File.expand_path(__FILE__))
		disable :run
		set :root,     "#{dir}/.."
		set :public_folder,   "#{dir}/../public"
		set :app_file, __FILE__
		set :views,    "app/views"
		enable :sessions
		set :session_secret, "My session secret"#debug only, to work with shotgun
		use Mixpanel::Tracker::Middleware, "0f98554b168f38500e5264ec8afefe3b", :async => true
		use Rack::Flash
		register Padrino::Mailer


		APP_KEYS = YAML.load(File.open "config/keys.yml")

		set :delivery_method, :smtp => { 
			:address              => APP_KEYS['email']['address'],
			:port                 => APP_KEYS['email']['port'],
			:user_name            => APP_KEYS['email']['uname'],
			:password             => APP_KEYS['email']['pass'],
			:authentication       => :plain,
			:enable_starttls_auto => true  
		}

		before do
			@nav = Hash.new()
			@pills = Hash.new()
			@mixpanel = Mixpanel::Tracker.new("0f98554b168f38500e5264ec8afefe3b", request.env, true)
		end

		get '/' do
			@nav[:home] = 'active'
			haml :index
		end

		get '/item' do
			@nav[:find] = 'active'

			@items = Item.all

			haml :'item/index'
		end

		get '/item/new' do
			login_required
			@nav[:share] = 'active'

			@item = Item.new

			haml :'item/create'
		end

		post '/item/new' do
			login_required
			@item = Item.new(params)
			if @item.valid?
				@item.save
				redirect '/item'
			else
				flash[:error] = "That item is not valid!"#TODO: improve this text
				redirect '/item/new'
			end
		end

		get '/item/:id' do |id|
			@item = Item.first(:id => id)
			haml :'item/profile'
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
			user = User.first(:email => params[:email])
			if not user.nil? and user.password == params[:password]
				session[:user] = user.id
				redirect '/login'#TODO: make this redirect to the incoming page!
			else
				flash[:forgot] = ''
				redirect '/login'
			end
		end

		post '/password-reset' do
			user = User.first(:email => params[:email])
			newpass = user.forgot_password
			#TODO: make this email less dumb
			email(:from => "reset@sharemat.ch", 
			      :to => user.email,
			      :subject => "Password Reset",
			      :body=>"Hi, we've given you a temporary password of #{newpass}. Login to reset.")
			flash[:sent] = ''
			redirect '/login'
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

			def include_scripts
				scripts = Dir.glob("public/scripts/*.js").map{|path| path.slice!("public") ; path }
				out = ""
				scripts.each{ |file| out << "%script{:src=>\"#{file}\",:type=>\"text/javascript\"}\n" }
				haml out
			end

			def index_funnel card, text
				el = ".index-funnel\n  %a.btn.success.large.scrollPage{:href =>'#{card}'} #{text}"
				haml el
			end

		end
	end
end
