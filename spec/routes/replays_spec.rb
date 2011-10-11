require_relative '../config'
require 'models/replay'

describe 'Replays routes' do
  include Rack::Test::Methods

  def app
    Application::Application
  end
  
  it "should return the list of replays" do   
    stub_request(:get, 'http://www.gosugamers.net/dota/replays?start=0').
    to_return(:body => File.new(File.join(File.dirname(__FILE__), '..', 'data', 'replays.html')))
    
    get '/replays?game=dota'

    last_response.should be_ok
    
    replays = JSON.parse(last_response.body)
    replays.count.should == 100
    
    replay = replays.first
    replay['id'].should == 51634
    replay['game'].should == 'dota'
    replay['date'].should == Date.parse('2011-10-10').to_s
    replay['player_one'].should == 'BK'
    replay['player_two'].should == 'DIE'
    replay['map'].should == 'v6.72f'
    replay['link'].should == 'http://www.gosugamers.net/replays/51634'
    replay['event'].should == 'ROCCAT DotA..'
    replay['comment_count'].should == 16
    replay['download_count'].should == 102
    replay['rating'].should == 6.8
  end
end