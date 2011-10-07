require_relative '../config'
require 'models/remote'

describe RemoteModel do
  def test_model(&block)
    model = Class.new(RemoteModel)
    model.class_eval(&block)
    model
  end
  
  it "should return the host based on site" do
    model = test_model { self.site = 'http://www.example.com/path' }
    model.host.should == 'http://www.example.com'
  end
  
  it "should add have a text field of type string" do
    model = test_model { field :text, String }
    model.has_field?(:text).should be_true
    model.field_type(:text).should == String
    lambda { model.text = 'text' }.should_not raise_error(RemoteModel::AttributeTypeMismatch)
  end
  
  it "should initialize attributes" do
    model = test_model { field :text, String }
    object = model.new(:text => 'example')
    object.text.should == 'example'
  end
  
  it "should throw an exception if an attribute is set with the wrong type" do
    model = test_model { field :text, String }
    object = model.new
    lambda { object.text = 5 }.should raise_error(RemoteModel::AttributeTypeMismatch)
  end
  
  it "should rename an argument before finding" do
    stub_request(:get, 'http://www.example.com?renamed_arg=renamed').
    to_return(:body => '<div>example</div>')
    
    model = test_model { 
      self.site = 'http://www.example.com'
      self.element_xpath = '//div'
      
      field :text, String
      
      rename_argument :arg, :renamed_arg
      
      def initialize_with_element(e, from_site = nil)
        self.text = e.content
      end
    }
    
    model.find(:arg => 'renamed').first.text.should == 'example'
  end
  
  it "should map an argument value before finding" do
    stub_request(:get, 'http://www.example.com?arg=8').
    to_return(:body => '<div>example</div>')
    
    model = test_model { 
      self.site = 'http://www.example.com'
      self.element_xpath = '//div'
      
      field :text, String
      
      map_argument(:arg) { |a| a * 2 }
      
      def initialize_with_element(e, from_site = nil)
        self.text = e.content
      end
    }
    
    model.find(:arg => 4).first.text.should == 'example'
  end
  
  it "should replace an argument with the new name and value before finding" do
    stub_request(:get, 'http://www.example.com?arg=replaced_arg').
    to_return(:body => '<div>example</div>')
    
    model = test_model { 
      self.site = 'http://www.example.com'
      self.element_xpath = '//div'
      
      field :text, String
      
      map_argument(:arg) { |a| 'replaced_' + a }
      
      def initialize_with_element(e, from_site = nil)
        self.text = e.content
      end
    }
    
    model.find(:arg => 'arg').first.text.should == 'example'
  end
  
  it "should use the default value when the argument is not passed" do
    stub_request(:get, 'http://www.example.com?arg=default').
    to_return(:body => '<div>example</div>')
    
    model = test_model { 
      self.site = 'http://www.example.com'
      self.element_xpath = '//div'
      
      field :text, String
      
      default_argument :arg, 'default'
      
      def initialize_with_element(e, from_site = nil)
        self.text = e.content
      end
    }
    
    model.find.first.text.should == 'example'
  end
  
  it "should find elements specified by the xpath" do
    stub_request(:get, 'http://www.example.com').
    to_return(:body => '<div><a href="link"></a></div>')
    
    model = test_model {
      self.site = 'http://www.example.com'
      self.element_xpath = '//div'
      
      field :link, String
      
      def initialize_with_element(e, from_site = nil)
        self.link = e.at_xpath('a')['href']
      end
    }
    
    model.find.first.link.should == 'link'
  end
  
  it "should sanitize content before parsing" do
    stub_request(:get, 'http://www.example.com').
    to_return(:body => '<div><a><h1>example</h1></a></div>')
    
    model = test_model {
      self.site = 'http://www.example.com'
      self.element_xpath = '//div'
      
      field :text, String
      
      sanitize_content do |content|
        content.gsub(/<\/?a>/, "")
      end
      
      sanitize_content do |content|
        content.gsub(/<\/?h1>/, "")
      end
      
      def initialize_with_element(e, from_site = nil)
        self.text = e.inner_html
      end
    }
    
    model.find.first.text.should == 'example'
  end
end