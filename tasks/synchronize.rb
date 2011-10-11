require 'models/news'
require 'models/match'
require 'models/replay'

task :environment do
  ENV['RACK_ENV'] ||= 'production'
end

namespace :db do
  namespace :synchronize do
    task :news => :environment do
      News.synchronize!
    end
    
    task :matches => :environment do
      Match.synchronize!
    end
    
    task :replays => :environment do
      Replay.synchronize!
    end
    
    task :all => [:news, :matches, :replays]
  end
  
  task :cron => :synchronize
end