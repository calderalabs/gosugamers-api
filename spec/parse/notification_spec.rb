require 'parse/notification'

describe Parse::Notification do
  it "should initialize with options" do
    notification = Parse::Notification.new(
      :type => 'ios',
      :channels => 'ch',
      :alert => 'Example',
      :badge => 1,
      :sound => 'snd',
      :custom_data => { :data => 'abc' }
    )
    
    notification.type.should == 'ios'
    notification.channels.first.should == 'ch'
    notification.alert.should == 'Example'
    notification.badge.should == 1
    notification.sound.should == 'snd'
    notification.custom_data.should == { :data => 'abc' }
  end
  
  it "should push with the provided options" do
    Parse::Request.stub!(:application_id).and_return('application_id')
    Parse::Request.stub!(:master_key).and_return('master_key')
    
    stub_request(:post, 'https://application_id:master_key@api.parse.com/1/push').
    with(
      :body => {
        :key => 'master_key',
        :type => 'ios',
        :channel => 'news',
        :data => {
          :alert => 'Example!',
          :badge => 0,
          :sound => nil,
          :foo => 'bar'
        }
      }.to_json,
      
      :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
    ).to_return(:body => { :success => true }.to_json)
    
    notification = Parse::Notification.new({
      :channels => 'news',
      :type => 'ios',
      :alert => 'Example!',
      :badge => 0,
      :custom_data => { :foo => 'bar' }
    })
    
    lambda { notification.push! }.should_not raise_error
  end
  
  it "should push to multiple channels" do
    Parse::Request.stub!(:application_id).and_return('application_id')
    Parse::Request.stub!(:master_key).and_return('master_key')
    
    channels = ['news', 'matches']
    
    channels.each do |channel|
      stub_request(:post, 'https://application_id:master_key@api.parse.com/1/push').
      with(
        :body => {
          :key => 'master_key',
          :type => 'ios',
          :channel => channel,
          :data => {
            :alert => 'Example!',
            :badge => 0,
            :sound => nil,
            :foo => 'bar'
          }
        }.to_json,
      
        :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
      ).to_return(:body => { :success => true }.to_json)
    end
    
    notification = Parse::Notification.new({
      :channels => channels,
      :type => 'ios',
      :alert => 'Example!',
      :badge => 0,
      :custom_data => { :foo => 'bar' }
    })
    
    lambda { notification.push! }.should_not raise_error
  end
end