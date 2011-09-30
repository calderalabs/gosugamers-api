require 'rack/test'
require 'sinatra'
require 'database_cleaner'
require 'factory_girl'
require 'mongoid'
require 'webmock/rspec'
require 'mongoid-rspec'

ENV['RACK_ENV'] = 'test'

require_relative '../application'
FactoryGirl.find_definitions

RSpec.configure do |config|
  config.include Mongoid::Matchers
  
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