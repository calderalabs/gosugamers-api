require 'models/news'
require 'models/match'
require 'redis'
require 'parse'

task :environment do
  ENV['RACK_ENV'] ||= 'production'
end

namespace :db do
  namespace :synchronize do
    task :news => :environment do
      redis = Redis.new
      [:starcraft, :starcraft2, :warcraft, :dota, :dota2, :hon, :wow, :diablo, :poker].each do |game|
        last_news_id = redis.get("last_news_#{game}")
        news = News.find(:page => 1, :game => game)
        redis.set("last_news_#{game}", news.first.id)
        next unless last_news_id
        news.keep_if { |n| n.id > last_news_id }.each { |n| n.to_notification.push! }
      end
    end
    
    task :matches => :environment do
      redis = Redis.new
      [:starcraft, :starcraft2, :warcraft, :dota, :hon].each do |game|
        last_match_id = redis.get("last_match_#{game}")
        matches = Match.find(:page => 1, :game => game)
        redis.set("last_match_#{game}", matches.first.id)
        next unless last_match_id
        matches.keep_if { |n| n.id > last_match_id }.each { |m| m.to_notification.push! }
      end
    end
    
    task :replays => :environment do
      redis = Redis.new
      [:starcraft, :starcraft2, :warcraft, :dota, :hon].each do |game|
        last_replay_id = redis.get("last_replay_#{game}")
        replays = Replay.find(:page => 1, :game => game)
        redis.set("last_replay_#{game}", replays.first.id)
        next unless last_replay_id
        replays.keep_if { |n| n.id > last_replay_id }.each { |r| r.to_notification.push! }
      end
    end
    
    task :all => [:news, :matches, :replays]
  end
  
  task :cron => :synchronize
end