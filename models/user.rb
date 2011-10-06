require 'models/subscribable'

class User
  include Mongoid::Document

  embeds_many :followed_teams, :class_name => 'Team'
  embeds_many :followed_games, :class_name => 'Game'
end

class Team < Subscribable
end

class Game < Subscribable
end