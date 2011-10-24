require 'open-uri'
require 'cgi'
require 'nokogiri'
require 'synchronizable'

class RemoteModel
  include Synchronizable
  
  AttributeTypeMismatch = Class.new(StandardError)
  SiteArgumentMissing = Class.new(StandardError)
  
  attr_reader :fetched_from
  
  class << self
    attr_accessor :site, :element_xpath
    
    private
    
    def fields
      @fields ||= {}
    end
    
    def renamed_arguments
      @renamed_arguments ||= {}
    end

    def mapped_arguments
      @mapped_arguments ||= {}
    end

    def default_arguments
      @default_arguments ||= {}
    end
    
    def content_sanitizers
      @content_sanitizers ||= []
    end
  end

  def self.host
    URI.split(site).values_at(0, 2).join('://') if site
  end

  def self.field_names
    fields.keys
  end

  def self.field_type(name)
    fields[name.to_sym]
  end
  
  def self.has_field?(name)
    fields.has_key?(name.to_sym)
  end

  def self.field(field, type)
    fields[field.to_sym] = type

    class_eval <<-EOT
      def #{field}
        @#{field}
      end
      
      def #{field}=(val)
        raise AttributeTypeMismatch,
          "\#{val.class.name} \#{val} cannot be assigned to " +
          "\#{self.class.field_type(:#{field}).name} field #{field}" unless val.is_a?(self.class.field_type(:#{field}))
          
        @#{field} = val
      end
    EOT
  end
  
  def initialize(attributes = {}, fetched_from = nil)
    attributes.each do |k, v|
      send("#{k}=", v)
    end
    
    @fetched_from = fetched_from
  end
  
  def initialize_with_element(e)
  end

  def self.rename_argument(argument, new_name)
    renamed_arguments[argument.to_sym] = new_name.to_sym
  end
  
  def self.map_argument(argument, &block)
    mapped_arguments[argument.to_sym] = block
  end

  def self.replace_argument(argument, new_name, &block)
    map_argument(argument, &block)
    rename_argument(argument, new_name)
  end

  def self.default_argument(argument, val)
    default_arguments[argument.to_sym] = val
  end

  def self.sanitize_content(&block)
    content_sanitizers << block
  end

  def self.find(args = {})
    return [] unless site
    
    args.delete_if { |k, v| v.nil? }
    args = default_arguments.merge(args)
    
    args.dup.each do |k, v|
      argument = k.to_sym
      mapped_argument = mapped_arguments[argument]
      args[argument] = mapped_argument.call(v) if mapped_argument
      renamed_argument = renamed_arguments[argument]
      args[renamed_argument] = args[argument] and args.delete(argument) if renamed_argument
    end
    
    url = site.gsub(/((:\w+)|\*)/) do |match|
      args.delete(match[1..-1].to_sym) or raise SiteArgumentMissing, "you must specify #{match} for #{site}"
    end
    
    query = args.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&') unless args.empty?
    contents  = open([url, query].compact.join('?')) { |f| f.read }
    content_sanitizers.each { |c| contents = c.call(contents) }
    
    doc = Nokogiri::HTML(contents) do |config|
      config.noerror
    end
    
    return [] unless doc
    
    doc.xpath(element_xpath).map do |e|
      model = self.new({}, url)
      model.initialize_with_element(e)
      model
    end
  end
  
  def attributes 
    self.class.field_names.each_with_object({}) do |field, attrs|
      attrs[field] = send(field)
    end
  end
  
  def to_json(*args)
    self.attributes.to_json(*args)
  end
end