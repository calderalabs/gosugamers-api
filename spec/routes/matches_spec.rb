require_relative '../config'
require 'models/match'

describe 'Matches routes' do
  include Rack::Test::Methods

  def app
    Application::Application
  end
  
  it "should return the list of matches" do   
    stub_request(:get, 'http://www.gosugamers.net/starcraft2/gosubet/upcoming/0').
    to_return(:body => File.new(File.join(File.dirname(__FILE__), '..', 'data', 'matches.html')))
    
    get '/matches?game=starcraft2'

    last_response.should be_ok
    
    matches = JSON.parse(last_response.body)
    matches.count.should == 32
    
    match = matches.first
    match['id'].should == 108450
    match['game'].should == 'starcraft2'
    match['eta'].should == '10h 30m'
    match['player_one'].should == 'HwangSin'
    match['player_two'].should == 'Jinro'
    match['link'].should == 'http://www.gosugamers.net/gosubet/108450'
    match['comment_count'].should == 0
    match['bet_count'].should == 23
  end
end