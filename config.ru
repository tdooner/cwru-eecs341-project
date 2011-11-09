$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/app')
require File.join(File.dirname(__FILE__), 'app', 'sharematch.rb')

set :environment, :development

require 'sharematch'

run ShareMatch::App.new

