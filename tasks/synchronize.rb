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
      last_date = redis.get('last_news_date') || 1.hour.ago
      
      [:starcraft, :starcraft2, :warcraft, :dota, :dota2, :hon, :wow, :diablo, :poker].each do |game|
        news = News.find(:page => 1, :game => game).
        keep_if { |n| n.created_at > last_date }
        news.to_notification.push! unless news.empty?
      end
      
      redis.set('last_news_date', Time.now)
    end
    
    task :all => [:news]
  end
  
  task :cron => :synchronize
end