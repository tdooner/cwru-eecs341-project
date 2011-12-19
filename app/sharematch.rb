require 'sinatra'
require 'haml'
require 'less'
require 'rack-flash'
require 'padrino-mailer'
require 'dm-pager'
require 'digest/md5'

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

    configure :development do
      set :session_secret, "My session secret"#debug only, to work with shotgun
    end

    configure :production do
      use Mixpanel::Tracker::Middleware, "0f98554b168f38500e5264ec8afefe3b", :async => true
    end

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

      @user = User.get( session[:user_id] ) if session[:user_id]
    end

    get '/' do
      @nav[:home] = 'active'
      haml :index
    end

    get '/item' do
      item_per_page = 12.0 #must be float for pages to be correctly calculated
      @nav[:find] = 'active'
      @page = 1
      @page = params[:page].to_i if params[:page]
      @pages = (Item.count / item_per_page).ceil

      if @page > @pages
        @page = @pages
      elsif @page < 1
        @page = 1
      end

      @items = Item.page @page, :per_page => item_per_page
      @tags = Tag.first 50

      if @user
        @trusted_users = @user.karmas.select{|x| x.type==true}.map{|x| x.unto}
        @blocked_users = @user.karmas.select{|x| x.type==false}.map{|x| x.unto}
        # Put the trusted items first by doing a set union. Although the trusted items are
        #  a subset of @items, doing a union like this will order them first.
        @items = @items.map{|x| x if @trusted_users.include?(x.user_id)}.compact | @items
      else
        @trusted_users = []
        @blocked_users = []
      end

      haml :'item/index'
    end

    get '/item/new' do
      login_required
      @nav[:share] = 'active'

      @item = Item.new

      haml :'item/create'
    end

    get '/item/:id/borrow' do |id|
      login_required
      item = Item.get(id)
      if not item.available?
        return {:success => false}.to_json
      end
      b = Borrowing.new(:user => @user, :item => item)
      if b.save
        return {:success => true}.to_json
      else
        puts b.errors.first
        return {:success => false}.to_json
      end
    end

    get '/item/:id/return' do |id|
      login_required
      item = Item.get(id)
      borrowership_required item
      borrowing = item.borrowings(:current => true).first
      borrowing.current = false
      borrowing.returned_at = Time.now
      if borrowing.save
        return {:success => true}.to_json
      else
        puts borrowing.errors.first
        return {:success => false}.to_json
      end
    end

    post '/item/new' do
      login_required
      params[:user_id] = @user.id
      params[:value].delete!('$,')
      @item = Item.new(params)
      if @item.valid?
        @item.save
        redirect "/item/#{@item.id}"
      else
        flash[:error] = "That item is not valid!"#TODO: improve this text
        redirect '/item/new'
      end
    end

    get '/item/:id' do |id|
      @item = Item.first(:id => id)
      if  @item.nil?
        haml :'404'
      else
        @similar = @item.get_similar 4, @item.tags
        @yours = true if @user == @item.user
        @helpfuls = Helpful.all(:user=>@user)
        @control_panel = get_item_control_panel @item
        @can_karma = @user && Karma.new({:from=>@user.id, :unto=>@item.user.id, :type=>true}).valid?
        haml :'item/profile' 
      end
    end

    post '/item/review' do
      login_required
      h = Helpful.first_or_new({:review_id => params['review_id'],
                               :user => @user})

      h[:helpful] = params['dir'] == 'up'? true : false
      if not h.save
        h.errors.each do |e|
          puts e
        end
      end

      rev = Review.get(params['review_id'])
      haml :'item/_votes', :layout => false, :locals => {:upd => rev.upDownVotes, 
        :helpfuls => Helpful.all(:user=>@user),
        :review_id => params['review_id'].to_i, 
        :divid => params['divid']}
    end


    post '/item/:id/tag' do |id|
      login_required
      item = Item.get(id)

      tag = Tag.first_or_create(:name => params['tag'])

      item.tags << tag

      item.save

      haml :'/item/_tags', :layout => false, :locals => {:item => item} 
    end

    get '/item/:id/edit' do |id|
      login_required
      @item = Item.first(:id => id)
      ownership_required @item
      @nav[:share] = 'active'
      haml :'item/edit'
    end

    post '/item/:id/edit' do |id|
      login_required
      puts params
      params[:value].delete!('$,')
      params.delete 'splat'
      params.delete 'captures'
      params.delete 'id'
      @item = Item.first(:id => id)
      must_be_this_person @item.user.id
      if @item.update(params)
        flash[:success] = 'Updated item succesfully'
        redirect "/item/#{id}"
      else
        flash[:error] = "Error saving item!"
      end
    end

    post '/item/:id' do |id|
      login_required
      @item = Item.first(:id => params[:item_id])
      @review = Review.new(:user => @user,
                           :item => @item,
                           :body => params['body'])
      if @review.valid?
        @review.save
      end

      redirect "/item/#{@item.id}"
    end

    get '/item/:id/delete' do |id|
      #sorry for not using verbs...
      item = Item.get(id)
      name = item.name
      if item.destroy
        flash[:success] = "#{name} is no longer shared."
        redirect "/user/#{@user.id}"
      else
        flash[:error] = "Item could not be unshared..."
        redirect request.referrer
      end
    end

    get '/tag/:id' do
      @nav[:find] = 'active'
      item_per_page = 12.0 #must be float for pages to be correctly calculated
      @page = 1
      @page = params[:page].to_i if params[:page]

      @tag = Tag.get(params[:id])                   # define this variable for the view
      @items = @tag.items
      @items = @items.page @page, :per_page => item_per_page

      @pages = (@items.count / item_per_page).ceil
      @tags = Tag.first 50
      #TODO: add ordering to tags based on popularity

      if @page > @pages
        @page = @pages
      elsif @page < 1
        @page = 1
      end

      haml :'item/index'
    end

    get '/search' do
      @nav[:search] = 'active'
      @results = []
      start = Time.now
      if params['query']
        if tag = Tag.first(:name => params['query'])
          @results.concat tag.items
        end
        @query = params['query']
        q = "%#{params['query']}%"
        @results.concat Item.all(:name.like => q) + Item.all( :desc.like => q)
      end
      @sec = (Time.now - start).to_s[0..5]
      haml :search
    end

    get '/sign-up' do
      @pills[:signup] = 'active'
      @step = 1
      @step = params[:step] if params[:step]

      # for debugging sign-up process, add &really=true to go to whichever step you want.
      unless params[:really]
        @step = 2 if params[:step] = 1 and @user
        @step = 3 if @user and @user.community
      end

      case @step.to_i
      when 1
        @user = User.new
      when 2
        self.login_required
        @communities = @user.closest_communities
      when 3
        self.login_required
        @item = Item.new
      end

      @part = "signup/_step#{@step}"

      haml :'signup/signup'
    end

    post '/sign-up' do
      case params[:step] 
      when "1"
        params.delete("step")
        @a = User.new(params)
        if @a.valid?
          @a.save
          session[:user_id] = @a.id
          redirect '/sign-up?step=2'
        else
          flash[:error] = @a.errors.first
          redirect '/sign-up'
        end
      when "2"
        self.login_required
        @user.community_id = params[:community_id]
        if @user.save
          redirect '/sign-up?step=3'
        else
          flash[:error] = "Could not join community!"
          redirect '/sign-up?step=2'
        end
      end
    end

    get '/login' do
      @pills[:login] = 'active'
      haml :login
    end

    post '/login' do
      user = User.first(:email => params[:email])
      if not user.nil? and user.password_hash == params[:password]
        path = session[:before_path]
        session[:before_path] = nil
        session[:user_id] = user.id
        redirect path || '/' 
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

    get '/communities' do
        haml :'community/index'
    end

    post '/communities/new' do
      self.login_required
      signup = params[:signup]
      params.delete('signup')
      c = Community.new(params)
      if c.valid? and c.save
        @user.community_id = c.id
        if @user.save
          # All went well!
          if signup
            redirect '/sign-up?step=3'
          else
            redirect "/community/#{c.id}"
          end
        else
          flash[:error] = "Could not join community!"
          if signup
            redirect '/sign-up?step=2'
          else
            redirect "/community/#{c.id}"
          end
        end
      else
        flash[:error] = "Could not create community!"
        if params[:sign_up]
          redirect '/sign-up?step=2'
        else
          redirect "/communities"
        end
      end
    end

    get '/community/:id' do |id|
      @c = Community.get(id)
      if @c.nil?
        haml :'404'
      else
        haml :'community/show'
      end
    end

    post '/community/join' do
      self.login_required
      id = params[:community_id]
      @user.community_id = id
      if @user.save
        redirect "/community/#{id}"
      else
        flash[:error] = "Could not join community!"
        redirect "/community/#{id}"
      end
    end

    get '/logout' do
      session[:user_id] = nil
      redirect '/'
    end

    get '/user' do
      user_per_page = 12.0 #must be float for pages to be correctly calculated
      @page = 1
      @page = params[:page].to_i if params[:page]
      @pages = (User.count / user_per_page).ceil

      if @page > @pages
        @page = @pages
      elsif @page < 1
        @page = 1
      end

      @users = User.page @page, :per_page => user_per_page

      haml :'user/index'
    end

    get '/user/:id' do |id|
      if @user && id.to_i == @user.id
        @you = true
        @u = @user
      else
        @you = false
        @u = User.get(id)
      end
      if @u.nil?
        haml :'404'
      else
        haml :'user/show'
      end
    end

    get '/user/:id/edit' do  |id|
      login_required
      must_be_this_person id
      @nav[:user] = 'active'
      @borrowings = @user.borrowings.select{|x| x.current == true}
      @items = @user.items
      haml :"user/edit"
    end

    post '/user/:id/edit' do |id|
      login_required
      must_be_this_person id
      @nav[:user] = 'active'
      params.delete("step")
      params.delete("splat")
      params.delete("captures")
      if params["password"] == ""
        params.delete("password")
        params.delete("password_repeat")
      end
      if @user.update(params)
        flash[:success] = 'Updated Profile succesfully'
        redirect "/user/#{id}"
      else
        flash[:error] = "Error updating profile"
      end
      haml :"user/edit"
    end

    get '/user/:id/delete' do |id|
      login_required
      must_be_this_person id
      if @user.destroy
        session.delete(:user_id)
        redirect "/"
      else
        flash[:error] = "Error removing profile."
        haml :"user/edit"
      end
    end

    post '/karma' do
        login_required
        a = Karma.new({
            :from => @user.id,
            :unto => params["user_id"],
            :type => (params["type"] == "block")?0:1
        })
        if a.save()
            return "Done!"
        else
            return a.errors.to_a.join("")
        end
    end

    get '/issue/new' do
      login_required
      item = Item.get(params['item'].to_i)
      borrowership_required item
      b = item.borrowings(:current => true).first
      if not b
        flash[:error] = "You're not borrowing that item!"
        redirect request.referrer
      end
      i = Issue.new(:borrowing => b)
      if i.save
        redirect "/issue/#{i.id}"
      else
        flash[:error] = "Error creating issue!"
        redirect request.referrer
      end
    end

    get '/issue/:id' do |id|
      login_required
      #TODO: add validation that users are involved
      @issue = Issue.get(id)
      if  @issue.nil?
        haml :'404'
      else
        haml :'issue/show'
      end
    end

    get '/admin' do
      login_required
      admin_required
      @issues = Issue.all
      @users = User.last(10)
      @borrowings = Borrowing.last(10)
      haml :'admin'
    end

    get '/admin/deleteuser/:id' do |id|
      login_required
      admin_required
      User.get(id).destroy
      redirect '/admin'
    end

    get '/issue/:id/resolve' do |id|
      i = Issue.get(id)
      i.resolved = true
      if i.save
        return {:success => true}.to_json
      end
    end

    get '/issue/:id/complain' do |id|
      i = Issue.get(id)
      i.admin_notified = true
      if i.save
        return {:success => true}.to_json
      end
    end

    not_found do
      haml :'404'
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
        if session[:user_id]
          return true
        else
          session[:before_path] = request.path
          redirect '/login'
        end
      end

      def ownership_required item
        if @user == item.user
          return true
        else
          flash[:error] = "You are not permitted to edit that item!"
          redirect  "/item/#{item.id}"
        end
      end

      def borrowership_required item
        if @user == item.currently_has
          return true
        else
          flash[:error] = "You are not permitted to return that item!"
          redirect  "/item/#{item.id}"
        end
      end


      def must_be_this_person id
        if @user.id == id.to_i
          return true
        else
          flash[:error] = "You are not permitted to edit that person!"
          redirect  "/user/#{id}"
        end
      end


      def current_user
        u = User.get(session[:user_id])
        if not request.xhr? and not u
          redirect '/login'
        end
        return u
      end

      def logged_in
        if session[:user_id]
            return true
        else
            return false
        end
      end

      def admin_required
        @user = User.get(session[:user_id])
        if session[:user_id] and @user and @user.is_admin?
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

      def gravatar user
        hash = Digest::MD5.hexdigest(user.email.downcase)
        "http://www.gravatar.com/avatar/#{hash}"
      end

      def get_item_control_panel item
        if not logged_in
          haml :'item/_control_panel' , :layout => false, :locals => {:item => item}
        elsif @user == item.user
          haml :'item/_owner_panel' , :layout => false, :locals => {:item => item}
        else
          ret = ""
          b = haml :'item/_borrower_panel' , :layout => false, :locals => {:item => item}
          n = haml :'item/_control_panel' , :layout => false, :locals => {:item => item}
          if @user == item.currently_has
            ret << "<div id='borrow-control'>"
            ret << b
            ret << "</div>"
            ret << "<div id='normal-control' class='hide'>"
            ret << n
            ret << "</div>"
            return ret
          else
            ret << "<div id='normal-control'>"
            ret << n
            ret << "</div>"
            ret << "<div id='borrow-control' class='hide'>"
            ret << b
            ret << "</div>"
            return ret
          end
        end
      end

    end
  end
end
