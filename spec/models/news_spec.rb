require_relative '../config'
require 'models/news'

describe News do  
  before(:each) do
    News.stub!(:site).and_return('http://www.example.com/:game/news')
    stub_request(:get, 'http://www.example.com/dota/news').
    to_return(:body => open(File.join(File.dirname(__FILE__), 'data', 'news.html')) { |f| f.read })
  end
  
  it 'should initialize its title' do
    n = News.new(:title => 'Awesome Title')
    n.title.should == 'Awesome Title'
  end
  
  it 'should initialize its link' do
    n = News.new(:link => 'http://www.example.com')
    n.link.should == 'http://www.example.com'
  end
  
  it 'should initialize its comment count' do
    n = News.new(:comment_count => 23)
    n.comment_count.should == 23
  end
  
  it 'should extract an array with the same fields from the sample html page' do
    news = News.find(:game => 'dota')
    news.first.title.should == 'Interview with pinksheep* from PMS Asterisk'
    news.first.link.should == 'http://www.example.com/news/17121-interview-with-pinksheep-from-pms-asterisk'
    news.first.comment_count.should == 12
  end
end