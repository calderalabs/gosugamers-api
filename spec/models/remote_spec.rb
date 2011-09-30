require_relative '../config'
require 'models/remote'

describe RemoteModel do
  before(:each) do
    stub_request(:get, 'http://www.example.com/models').
    to_return(:body => 'example')
  end
  
  it 'should initialize its id' do
    m = RemoteModel.new(:id => 1)
    m.id.should == 1
  end
  
  it 'should not return any model from contents' do
    RemoteModel.extract_from_contents('anything').should be_nil
  end
  
  it 'should pass the contents of the specified website' do
    RemoteModel.should_receive(:extract_from_contents).with('example')
    RemoteModel.find_from_site('http://www.example.com/models')
  end

  it 'should use the site attribute when using find' do
    RemoteModel.should_receive(:extract_from_contents).with('example')
    RemoteModel.site = 'http://www.example.com/models'
    RemoteModel.find
  end
end