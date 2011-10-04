require_relative '../config'
require 'models/remote'

describe RemoteModel do
  def test_model(&block)
    model = Class.new(RemoteModel)
    model.class_eval(&block)
    model
  end
  
  before(:each) do
    stub_request(:get, /.*example.*/)
  end
  
  it "should return the host based on site" do
    model = test_model { self.site = 'http://www.example.com/path' }
    model.host.should == 'http://www.example.com'
  end
  
  it "should add have a text field of type string" do
    model = test_model { field :text, String }
    model.field_type(:text).should == String
  end
  
  it "should initialize attributes" do
    model = test_model { field :text, String }.new(:text => 'example')
    model.text.should == 'example'
  end
  
  it "should rename an argument before finding" do
    model = test_model { 
      self.site = 'http://www.example.com'
      rename_argument :arg, :renarg
    }
    
    model.find(:arg => 'rename this')
    should have_requested(:get, 'http://www.example.com').with(:query => { 'renarg' => 'rename this' })
  end
  
  it "should map an argument value before finding" do
    model = test_model {
      self.site = 'http://www.example.com'
      map_argument(:arg) { |a| a * 2 }
    }
      
    model.find(:arg => 4)
    should have_requested(:get, 'http://www.example.com').with(:query => { 'arg' => '8' })
  end
  
  it "should replace an argument with the new name and value before finding" do
    model = test_model {
      self.site = 'http://www.example.com'
      replace_argument(:arg, :reparg) { |a| a + ' replaced' }
    }
    
    model.find(:arg => 'example')
    should have_requested(:get, 'http://www.example.com').with(:query => { 'reparg' => 'example replaced' })
  end
  
  it "should use the default value when the argument is not passed" do
    model = test_model {
      self.site = 'http://www.example.com'
      default_argument(:arg, 'default')
    }
    
    model.find
    should have_requested(:get, 'http://www.example.com').with(:query => { 'arg' => 'default' })
  end
end