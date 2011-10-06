require_relative '../config'
require 'models/news'

describe 'News routes' do
  include Rack::Test::Methods

  def app
    Application::Application
  end
  
  it "should return the list of news"
end