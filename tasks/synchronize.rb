require 'models/news'
require 'models/user'

task :environment do
  ENV['RACK_ENV'] ||= 'production'
  Application.initialize_db
end

namespace :db do
  namespace :synchronize do
    task :news => :environment do
      map = <<-EOT
        function() {
          if(!this.followed_games)
            return;
            
          this.followed_games.forEach(function(g) {
            emit('created_at', g.created_at);
          });
        }
      EOT
      
      reduce = <<-EOT
        function(key, values) {
          min = values[0];
          
          values.forEach(function(v) {
            if(v < min)
              min = v;
          })
          
          return min;
        }
      EOT
      
      target_date =
      Application.global['news_synced_at'] ||
      User.collection.map_reduce(map, reduce, :out => {:inline => 1}, :raw => true)['results'].first
      
      next unless target_date
      
      news = []
      
      1.upto(10) do |page|
        news += News.find(:page => page)
        break if news.last.created_at < target_date
      end
      
      Application.global['news_synced_at'] = Time.now
    end
    
    task :all => [:news]
  end
  
  task :cron => :synchronize
end