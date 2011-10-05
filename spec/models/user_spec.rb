require_relative '../config'
require 'models/user'

describe User do
  include Mongoid::Matchers
  
  it { should have_field(:followed_teams).of_type(Array) }
  it { should have_field(:_id).of_type(Integer) }
end