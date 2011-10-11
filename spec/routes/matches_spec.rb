require_relative '../config'
require 'models/match'

describe 'Matches routes' do
  include Rack::Test::Methods

  def app
    Application::Application
  end
  
  it "should return the list of matches" do   
    stub_request(:get, 'http://www.gosugamers.net/dota/gosubet?start=0').
    to_return(:body => File.new(File.join(File.dirname(__FILE__), '..', 'data', 'matches.html')))
    
    get '/matches?game=dota'

    last_response.should be_ok
    
    matches = JSON.parse(last_response.body)
    matches.count.should == 13
    
    match = matches.first
    match['id'].should == 107580
    match['game'].should == 'dota'
    match['eta'].should == '1h 51m'
    match['player_one'].should == 'XBOCT+4'
    match['player_two'].should == 'monkey'
    match['link'].should == 'http://www.gosugamers.net/gosubet/107580'
    match['comment_count'].should == 12
    match['bet_count'].should == 170
  end
end