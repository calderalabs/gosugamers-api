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

module Application
  def self.initialize!
    Parse::Configuration.configure do |config|
      config.application_id = 'KT03lBl47kQ7mFcFu2A7OsVddHcxAwLroITBP6MM'
      config.master_key = 'YHRqssmllNOqCLFXU5ePyBirKspBsDArdo3olpV3'
    end
    
    config = YAML::load(File.open(File.join(root, 'config', 'redis.yml')))
    $redis = Redis.new(config[environment])
  end
  
  def self.root
    APP_ROOT
  end
  
  def self.environment
    ENV['RACK_ENV'] || 'development'
  end
end