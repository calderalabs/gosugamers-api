require 'models/news'
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
    
    task :all => [:news]
  end
  
  task :cron => :synchronize
end