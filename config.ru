$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'app')

require 'sharematch'

run ShareMatch::App.new

