require 'bundler/setup'
Bundler.require(:default)
require './app'

use Rack::Session::Cookie, :secret => 'r32823789234789ehdhjhh382789rhsdhfjds'
run ControlPanel
