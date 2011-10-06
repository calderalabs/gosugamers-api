require_relative '../config'
require 'models/user'

describe User do
  include Mongoid::Matchers
  
  it { should embed_many(:followed_teams).of_type(Team) }
  it { should embed_many(:followed_games).of_type(Game) }
end