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

	desc "Run all pending migrations, or up to specified migration"
	task :migrate, [:version] => :load_migrations do |t, args|
		if vers = args[:version] || ENV['VERSION']
			puts "=> Migrating up to version #{vers}"
			migrate_up!(vers)
		else
			puts "=> Migrating up"
			migrate_up!
		end
		puts "<= #{t.name} done"
	end

	desc "Rollback down to specified migration, or rollback last STEP=x migrations (default 1)"
	task :rollback, [:version] => :load_migrations do |t, args|
		if vers = args[:version] || ENV['VERSION']
			puts "=> Rolling back down to migration #{vers}"
			migrate_down!(vers)
		else
			step = ENV['STEP'].to_i || 1
			applied = migrations.delete_if {|m| m.needs_up?}.sort   # note this is N queries as currently implemented
			target = applied[-1 * step] || applied[0]
			if target
				puts "=> Rolling back #{step} step(s)"
				migrate_down!(target.position - 1)
			else
				warn "No migrations to rollback: #{step} step(s)"
			end
		end
		puts "<= #{t.name} done"
	end

	desc "List migrations descending, showing which have been applied"
	task :migrations => :load_migrations do
		puts migrations.sort.reverse.map {|m| "#{m.position}  #{m.name}  #{m.needs_up? ? '' : 'APPLIED'}"}
	end

	task :load_migrations => :environment do
		require 'dm-migrations/migration_runner'
		FileList['db/migrate/*.rb'].each do |migration|
			load migration
		end
	end


end

task :environment do
	$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/app')
	require File.join(File.dirname(__FILE__), 'app', 'sharematch.rb')
end

