require_relative '../config'
require 'models/news'

describe 'News routes' do
  include Rack::Test::Methods

  def app
    Application::Application
  end
  
  it "should return the list of news" do   
    stub_request(:get, 'http://www.gosugamers.net/dota/news/archive').
    to_return(:body => open(File.join(File.dirname(__FILE__), '..', 'data', 'news.html')) { |f| f.read })
    
    get '/news?game=dota'
    
    last_response.should be_ok
    news = JSON.parse(last_response.body).first

    news['game'].should == 'dota'
    news['title'].should == 'Interview with pinksheep* from PMS Asterisk'
    news['link'].should == 'http://www.gosugamers.net/news/17121-interview-with-pinksheep-from-pms-asterisk'
    news['comment_count'].should == 12
    news['created_at'].should == DateTime.parse('2011-10-02 07:20:51 CET').to_s
  end
end