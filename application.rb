APP_ROOT = File.dirname(__FILE__)
$LOAD_PATH.push(APP_ROOT)

require 'sinatra/base'

require 'models/remote'
require 'routes/news'
require 'routes/bets'
require 'routes/replays'
require 'parse'

module Application
  def self.configure
    Parse::Configuration.configure do |c|
      c.application_id = 'KT03lBl47kQ7mFcFu2A7OsVddHcxAwLroITBP6MM'
      c.master_key = 'YHRqssmllNOqCLFXU5ePyBirKspBsDArdo3olpV3'
    end
  end
end