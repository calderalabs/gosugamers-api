require 'parse/configuration'

describe Parse::Configuration do
  it "should configure master key and application id" do
    Parse::Request.should_receive(:'master_key=').with('master_key')
    Parse::Request.should_receive(:'application_id=').with('application_id')
    
    config = Parse::Configuration.new
    config.master_key = 'master_key'
    config.application_id = 'application_id'
    config.configure!
  end
end