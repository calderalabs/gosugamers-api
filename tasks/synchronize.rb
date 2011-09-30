require 'rss/2.0'
require 'open-uri'

namespace :db do
  namespace :synchronize do
    task :news => :environment do
      News.find(:page => 1).each do |n|
      end
    end
    
    task :all => [:news, :bets, :replays]
  end
  
  task :cron => :synchronize
end