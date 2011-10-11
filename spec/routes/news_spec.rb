require_relative '../config'
require 'models/news'

describe 'News routes' do
  include Rack::Test::Methods

  def app
    Application::Application
  end
  
  it "should return the list of news" do   
    stub_request(:get, 'http://www.gosugamers.net/dota/news/archive?start=0').
    to_return(:body => File.new(File.join(File.dirname(__FILE__), '..', 'data', 'news.html')))
    
    get '/news?game=dota'
    
    last_response.should be_ok
    news = JSON.parse(last_response.body)
    news.count.should == 25
    
    first_news = news.first
    first_news['game'].should == 'dota'
    first_news['title'].should == 'Interview with pinksheep* from PMS Asterisk'
    first_news['link'].should == 'http://www.gosugamers.net/news/17121-interview-with-pinksheep-from-pms-asterisk'
    first_news['comment_count'].should == 12
    first_news['created_at'].should == DateTime.parse('2011-10-02 07:20:51 CET').to_s
  end
end