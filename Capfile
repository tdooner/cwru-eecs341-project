load 'deploy' if respond_to?(:namespace) # cap2 differentiator

desc "Restart the server."
namespace :deploy do
    desc "Restart the server"
    task :restart, :on_error => :continue do
        run "cd #{current_path} && bundle exec thin stop -a 0.0.0.0 -e 'production' -p 4567 -d -c #{current_path} -R ./config.ru"
        run "cd #{current_path} && bundle exec thin start -a 0.0.0.0 -e 'production' -p 4567 -d -c #{current_path} -R ./config.ru"
    end
    desc "Make keys.yml"
    task :keys_file do
        run "ln -s #{shared_path}/config/keys.yml #{release_path}/config/keys.yml"
    end
    desc "Initialize the database."
    task :db_rebuild do
        run "cd #{current_path} && #{rake} db:rebuild"
        run "cd #{current_path} && #{rake} db:seed[10] RACK_ENV=production"
        run "cd #{current_path} && #{rake} db:load_zip_codes RACK_ENV=production > /dev/null"
    end
end

desc "Run the rake tests on the new install."
task :run_tests do
    run "cd #{current_path} && #{rake} test"
end

before "deploy:restart", "deploy:keys_file"
before "deploy:restart", "deploy:db_rebuild"
after "deploy", "run_tests"


Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

load 'config/deploy' # remove this line to skip loading any of the default tasks
