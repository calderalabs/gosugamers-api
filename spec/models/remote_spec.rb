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
      map_argument :arg do |a| a * 2 end
    }
      
    model.find(:arg => 4)
    should have_requested(:get, 'http://www.example.com').with(:query => { 'arg' => '8' })
  end
end