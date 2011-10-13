require 'rack/test'
require 'sinatra'
require 'webmock/rspec'

ENV['RACK_ENV'] ||= 'test'

require_relative '../application'
require_relative 'matchers'

Application.initialize!

RSpec.configure do |config|
  config.before(:each) { $redis.flushall }
end
