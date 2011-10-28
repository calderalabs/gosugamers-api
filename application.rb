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
require 'erb'

module Application
  def self.initialize!
    parse = YAML::load(ERB.new(File.read(File.join(root, 'config', 'parse.yml'))).result)

    Parse::Configuration.configure do |config|
      config.application_id = parse['application_id']
      config.master_key = parse['master_key']
    end
    
    redis = YAML::load(ERB.new(File.read(File.join(root, 'config', 'redis.yml'))).result)
    $redis = Redis.new(redis[environment])
  end
  
  def self.root
    APP_ROOT
  end
  
  def self.environment
    ENV['RACK_ENV'] || 'development'
  end
end