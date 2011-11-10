require 'rubygems'
require 'bundler/setup'
require 'rspec/core/rake_task'

task :default => :test
task :test => :spec


if !defined?(RSpec)
	puts "spec targets require RSpec"
else
	desc "Run all examples"
	RSpec::Core::RakeTask.new(:spec) do |t|
		t.rspec_opts = ['-cfs']
	end
end


namespace :db do

	desc 'Nuke the database and build back up from nothing'
	task :rebuild => :environment do
		DataMapper.auto_migrate!
	end

	desc 'Add new fields to database without nuking everything'
	task :upgrade => :environment do
		DataMapper.auto_upgrade!
	end

	desc 'Load seed data into database for testing and demonstration'
	task :seed => :environment do
		puts 'Will be implemented soon'
	end

end

task :environment do
	$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/app')
	require File.join(File.dirname(__FILE__), 'app', 'sharematch.rb')
end

