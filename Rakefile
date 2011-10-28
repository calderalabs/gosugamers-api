require_relative 'application'
Application.initialize!

require_relative 'tasks/spec'

require 'resque/tasks'
require 'resque_scheduler/tasks'    

namespace :resque do
    task :setup do
        require 'resque'
        require 'resque_scheduler'
        require 'resque/scheduler'      

        Resque.redis = $redis
        Resque.schedule = YAML.load_file(File.join(Application.root, 'config', 'schedule.yml'))
        
        require_relative 'tasks/synchronize'
    end
end
