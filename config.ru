$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/app')

require 'sharematch'
run ShareMatch::App.new

