require_relative '../config'
require 'models/remote'

describe RemoteModel do
  before(:each) do
    stub_request(:get, 'http://www.example.com/objects').
    to_return(:body => 'example')
  end
end