require 'rack/test'
require 'sinatra'
require 'database_cleaner'
require 'factory_girl'
require 'mongoid'
require 'webmock/rspec'
require 'mongoid-rspec'

ENV['RACK_ENV'] = 'test'

require_relative '../application'
require_relative 'matchers'

FactoryGirl.find_definitions

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end