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
    stub_request(:get, 'http://www.gosugamers.net/dota/gosubet').
    to_return(:body => File.new(File.join(File.dirname(__FILE__), '..', 'data', 'matches.html')))
    
    matches = Match.find(:game => 'dota')
    matches.count.should == 13
    
    match = matches.first
    match.id.should == 107580
    match.game.should == 'dota'
    match.eta.should == '1h 51m'
    match.player_one.should == 'XBOCT+4'
    match.player_two.should == 'monkey'
    match.link.should == 'http://www.gosugamers.net/gosubet/107580'
    match.comment_count.should == 12
    match.bet_count.should == 170
  end
end