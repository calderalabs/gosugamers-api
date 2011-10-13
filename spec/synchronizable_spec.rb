require_relative 'config'
require 'synchronizable'

module SynchronizableSpec
  class Notification
    attr_accessor :id
    
    def self.push!(id)
    end
    
    def initialize(id)
      self.id = id
    end
    
    def push!
      self.class.push!(id)
    end
  end

  class Synchronized
    include Synchronizable
  
    def self.create(id)
      s = new
      s.id = id
      s
    end
  
    attr_accessor :id
    synchronizable_on :some, :example, :game
  
    def self.find(args = {})
      case args[:game]
      when :some
        [create(3), create(2), create(1)]
      when :example
        [create(6), create(5), create(4)]
      when :game
        [create(9), create(8), create(7)]
      end
    end
  
    def to_notification
      SynchronizableSpec::Notification.new(id)
    end
  end
end

describe Synchronizable do
  it "should just set the most recent ids the first time" do
    Parse::Request.stub!(:application_id).and_return('application_id')
    Parse::Request.stub!(:master_key).and_return('master_key')

    SynchronizableSpec::Notification.should_not_receive(:push!)
    SynchronizableSpec::Synchronized.synchronize!
    
    JSON.parse($redis.get('last_synchronizablespec::synchronized_some'))['id'].should == 3
    JSON.parse($redis.get('last_synchronizablespec::synchronized_example'))['id'].should == 6
    JSON.parse($redis.get('last_synchronizablespec::synchronized_game'))['id'].should == 9
  end
  
  it "should push notifications for new items" do
    Parse::Request.stub!(:application_id).and_return('application_id')
    Parse::Request.stub!(:master_key).and_return('master_key')
    
    $redis.set('last_synchronizablespec::synchronized_some', { :id => 2 }.to_json)
    $redis.set('last_synchronizablespec::synchronized_example', { :id => 5 }.to_json)
    $redis.set('last_synchronizablespec::synchronized_game', { :id => 9 }.to_json)
    
    SynchronizableSpec::Notification.should_receive(:push!).with(3)
    SynchronizableSpec::Notification.should_receive(:push!).with(6)
    SynchronizableSpec::Synchronized.synchronize!
  end
end