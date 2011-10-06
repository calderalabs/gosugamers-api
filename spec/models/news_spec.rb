require_relative '../config'
require 'models/news'

describe News do    
  it { should have_field(:title).of_type(String) }
  it { should have_field(:link).of_type(String) }
  it { should have_field(:comment_count).of_type(Integer) }
  it { should have_field(:created_at).of_type(DateTime) }
  
  it 'should find the news from the example data' do
    News.stub!(:site).and_return('http://www.example.com/:game/news')
        
    stub_request(:get, 'http://www.example.com/dota/news').
    to_return(:body => open(File.join(File.dirname(__FILE__), 'data', 'news.html')) { |f| f.read })
    
    news = News.find(:game => 'dota')
    news.first.title.should == 'Interview with pinksheep* from PMS Asterisk'
    news.first.link.should == 'http://www.example.com/news/17121-interview-with-pinksheep-from-pms-asterisk'
    news.first.comment_count.should == 12
    news.first.created_at.should == DateTime.parse('2011-10-02 07:20:51 CET')
  end
end