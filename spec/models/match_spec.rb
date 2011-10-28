require_relative '../config'
require 'models/match'

describe Match do    
  it { should have_field(:id).of_type(Integer) }
  it { should have_field(:eta).of_type(String) }
  it { should have_field(:game).of_type(String) }
  it { should have_field(:player_one).of_type(String) }
  it { should have_field(:player_two).of_type(String) }
  it { should have_field(:link).of_type(String) }
  it { should have_field(:comment_count).of_type(Integer) }

  it 'should find the matches from the example data' do   
    stub_request(:get, 'http://www.gosugamers.net/starcraft2/gosubet/upcoming/0').
    to_return(:body => File.new(File.join(File.dirname(__FILE__), '..', 'data', 'matches.html')))
    
    matches = Match.find(:game => 'starcraft2')
    matches.count.should == 32
    
    match = matches.first
    match.id.should == 108450
    match.game.should == 'starcraft2'
    match.eta.should == '10h 30m'
    match.player_one.should == 'HwangSin'
    match.player_two.should == 'Jinro'
    match.link.should == 'http://www.gosugamers.net/gosubet/108450'
    match.comment_count.should == 0
    match.bet_count.should == 23
  end
end