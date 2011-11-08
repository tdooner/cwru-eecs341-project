$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/app')

require 'sharematch'
require 'models/Models.rb'          # since /app is in $LOAD_PATH

run ShareMatch::App.new

