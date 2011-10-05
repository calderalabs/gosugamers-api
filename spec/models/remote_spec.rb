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
    model.has_field?(:text).should be_true
    model.field_type(:text).should == String
  end
  
  it "should initialize attributes" do
    model_object = test_model { field :text, String }.new(:text => 'example')
    model_object.text.should == 'example'
  end
  
  it "should throw an exception if an attribute is set with the wrong type" do
    model_object = test_model { field :text, String }.new
    lambda { model_object.text = 5 }.should raise_error(RemoteModel::AttributeTypeMismatch)
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
  
  it "should find elements specified by the xpath" do
    stub_request(:get, 'http://www.example.com/elements').
    to_return(:body => '<div><a href="link"></a></div>')
    
    model = test_model {
      self.site = 'http://www.example.com/elements'
      self.element_xpath = '//div'
      
      field :link, String
      
      def initialize_with_element(e)
        self.link = e.at_xpath('a')['href']
      end
    }
    
    model.find.first.link.should == 'link'
  end
  
  it "should sanitize content before parsing" do
    stub_request(:get, 'http://www.example.com/elements').
    to_return(:body => 'body')
    
    model = test_model {
      self.site = 'http://www.example.com/elements'
      
      sanitize_content do |content|
        content + ' one'
      end
      
      sanitize_content do |content|
        content + ' two'
      end
    }
    
    Nokogiri.should_receive(:HTML).with('body one two')
    model.find
  end
end