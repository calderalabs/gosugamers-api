require 'parse/request'

describe Parse::Request do
  it "should initialize its path, method and arguments" do
    request = Parse::Request.new('path', :get, { :arg => 'value' })
    request.path.should == 'path'
    request.method.should == :get
    request.args.should == { :arg => 'value' }
  end
  
  it "should call the specified resource with the provided arguments and method" do
    Parse::Request.stub!(:application_id).and_return('application_id')
    Parse::Request.stub!(:master_key).and_return('master_key')
    
    stub_request(:get, 'https://application_id:master_key@api.parse.com/1/path').
    with(:body => {:arg => 'value' }.to_json,
    :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }).
    to_return(:body => { 'success' => true }.to_json)
    
    request = Parse::Request.new('path', :get, { :arg => 'value' })
    request.execute! do |status, response|
      status.should == 200
      response.should == { 'success' => true }
    end
  end

  it "should raise a configuration error when no master key is provided" do
    Parse::Request.stub!(:master_key).and_return(nil)
    
    lambda { Parse::Request.execute!('path') }.should raise_error(Parse::Request::ConfigurationError)
  end
  
  it "should raise a configuration error when no application id is provided" do
    Parse::Request.stub!(:application_id).and_return(nil)
    
    lambda { Parse::Request.execute!('path') }.should raise_error(Parse::Request::ConfigurationError)
  end
  
  it "should raise an argument error when no path is provided" do
    lambda { Parse::Request.execute!(nil) }.should raise_error(ArgumentError)
  end
end