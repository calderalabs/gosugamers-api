APP_ROOT = File.dirname(__FILE__)
$LOAD_PATH.push(APP_ROOT)

require 'sinatra/base'

require 'models/remote'
require 'routes/news'
require 'routes/matches'
require 'routes/replays'
require 'parse'
require 'json'
require 'yaml'
require 'redis'
require 'additions/hash'

module Application
  def self.initialize!
    parse = YAML::load(File.open(File.join(root, 'config', 'parse.yml')))[environment].symbolize_keys

    Parse::Configuration.configure do |config|
      config.application_id = parse[:application_id]
      config.master_key = parse[:master_key]
    end
    
    redis = YAML::load(File.open(File.join(root, 'config', 'redis.yml')))
    $redis = Redis.new(redis[environment].symbolize_keys)
  end
  
  def self.root
    APP_ROOT
  end
  
  def self.environment
    ENV['RACK_ENV'] || 'development'
  end
end