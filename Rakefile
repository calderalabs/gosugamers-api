require 'mongoid'

require_relative 'tasks/synchronize'
require_relative 'tasks/spec'

task :environment do
  ENV['RACK_ENV'] ||= 'development'
  Mongoid.logger = false
  Mongoid.load!('config/mongoid.yml')
end
