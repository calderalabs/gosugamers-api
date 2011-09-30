require_relative '../config'
require 'models/news'

describe News do
  before { News.site = 'http://www.example.com' }
  
  it 'should initialize its title' do
    n = News.new(:title => 'Awesome Title')
    n.title.should == 'Awesome Title'
  end
  
  it 'should initialize its description' do
    n = News.new(:description => 'Awesome description')
    n.description.should == 'Awesome description'
  end
  
  it 'should initialize its link' do
    n = News.new(:link => 'http://www.example.com')
    n.link.should == 'http://www.example.com'
  end
  
  it 'should append the game name to the site' do
    News.should_receive(:find_from_site).with('http://www.example.com/dota', :game => 'dota')
    News.find(:game => 'dota')
  end
  
  it 'should use general site if no game is specified' do
    News.should_receive(:find_from_site).with('http://www.example.com/general')
    News.find
  end
end