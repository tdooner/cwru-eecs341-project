load 'deploy' if respond_to?(:namespace) # cap2 differentiator

desc "Restart the server."
namespace :deploy do
    task :restart do
        run "cd /var/www/html_tom/sharematch/current/ && screen -d -m -S sharematch sh run.sh"
    end
end
# Uncomment if you are using Rails' asset pipeline
# load 'deploy/assets'

Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

load 'config/deploy' # remove this line to skip loading any of the default tasks
