class User
  include Mongoid::Document
  identity :type => Integer
  field :followed_teams, :type => Array
end