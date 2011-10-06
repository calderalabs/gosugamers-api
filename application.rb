APP_ROOT = File.dirname(__FILE__)
$LOAD_PATH.push(APP_ROOT)

require 'sinatra/base'

require 'models/remote'
require 'routes/news'
require 'routes/bets'
require 'routes/replays'

module Application
  def self.initialize_db
    Mongoid.load!('config/mongoid.yml')
  end
  
  def self.global
    collection = Mongoid.database['global']
    
    if collection.count != 0
      collection.find_one()
    else
      collection.insert({})
      collection.find_one()
    end
  end
end