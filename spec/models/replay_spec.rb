require_relative '../config'
require 'models/replay'

describe Replay do    
  it { should have_field(:id).of_type(Integer) }
  it { should have_field(:date).of_type(Date) }
  it { should have_field(:game).of_type(String) }
  it { should have_field(:player_one).of_type(String) }
  it { should have_field(:player_two).of_type(String) }
  it { should have_field(:map).of_type(String) }
  it { should have_field(:link).of_type(String) }
  it { should have_field(:event).of_type(String) }
  it { should have_field(:comment_count).of_type(Integer) }
  it { should have_field(:download_count).of_type(Integer) }
  it { should have_field(:rating).of_type(Float) }
  
  it 'should find the replays from the example data' do   
    stub_request(:get, 'http://www.gosugamers.net/dota/replays').
    to_return(:body => File.new(File.join(File.dirname(__FILE__), '..', 'data', 'replays.html')))
    
    replay = Replay.find(:game => 'dota').first
    replay.id.should == 51634
    replay.game.should == 'dota'
    replay.date.should == Date.parse('2011-10-10')
    replay.player_one.should == 'BK'
    replay.player_two.should == 'DIE'
    replay.map.should == 'v6.72f'
    replay.link.should == 'http://www.gosugamers.net/replays/51634'
    replay.event.should == 'ROCCAT DotA..'
    replay.comment_count.should == 16
    replay.download_count.should == 102
    replay.rating.should == 6.8
  end
end