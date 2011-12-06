require "bundler/capistrano"

set :application, "sharemat.ch"
set :repository,  "git://github.com/ted27/cwru-eecs341-project.git"

set :scm, "git"
set :user, "tom"
set :branch, "master"
set :deploy_to, "/var/www/html_tom/sharematch/"
set :use_sudo, :false
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "sharemat.ch"                          # Your HTTP server, Apache/etc
role :app, "sharemat.ch"                          # This may be the same as your `Web` server
role :db,  "sharemat.ch", :primary => true # This is where Rails migrations will run

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
