load 'deploy' if respond_to?(:namespace) # cap2 differentiator

desc "Restart the server."
namespace :deploy do
    task :restart, :on_error => :continue do
        run "cd #{release_path} && bundle exec thin stop -a 0.0.0.0 -e 'production' -p 4567 -d -R ./config.ru"
        run "cd #{release_path} && bundle exec thin start -a 0.0.0.0 -e 'production' -p 4567 -d -R ./config.ru"
    end
    task :keys_file do
        run "ln -s #{shared_path}/config/keys.yml #{release_path}/config/keys.yml"
    end
end

after "deploy:finalize_update", "deploy:keys_file"


Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

load 'config/deploy' # remove this line to skip loading any of the default tasks
