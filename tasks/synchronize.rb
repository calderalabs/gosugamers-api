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
      last_date = redis.get('last_date') || 1.hour.ago
      
      news = News.find(:page => 1, :game => 'dota').
      keep_if { |n| n.created_at > last_date }
      news.to_notification.push! unless news.empty?
      
      redis.set('last_date', Time.now)
    end
    
    task :all => [:news]
  end
  
  task :cron => :synchronize
end