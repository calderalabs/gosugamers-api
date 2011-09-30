APP_ROOT = File.dirname(__FILE__)
$LOAD_PATH.push(APP_ROOT)

require 'sinatra/base'

require 'models/remote'
require 'routes/news'
require 'routes/bets'
require 'routes/replays'

Mongoid.load!('config/mongoid.yml')