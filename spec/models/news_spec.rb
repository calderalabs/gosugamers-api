require_relative '../config'
require 'models/news'

describe News do    
  it { should have_field(:id).of_type(Integer) }
  it { should have_field(:title).of_type(String) }
  it { should have_field(:link).of_type(String) }
  it { should have_field(:comment_count).of_type(Integer) }
  it { should have_field(:created_at).of_type(DateTime) }
  
  it 'should find the news from the example data' do   
    stub_request(:get, 'http://www.gosugamers.net/dota/news/archive').
    to_return(:body => File.new(File.join(File.dirname(__FILE__), '..', 'data', 'news.html')))
    
    news = News.find(:game => 'dota')
    news.count.should == 25
    
    first_news = news.first
    first_news.id.should == 17121
    first_news.game.should == 'dota'
    first_news.title.should == 'Interview with pinksheep* from PMS Asterisk'
    first_news.link.should == 'http://www.gosugamers.net/news/17121-interview-with-pinksheep-from-pms-asterisk'
    first_news.comment_count.should == 12
    first_news.created_at.should == DateTime.parse('2011-10-02 07:20:51 CET')
  end
end