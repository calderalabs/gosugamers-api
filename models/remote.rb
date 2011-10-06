require 'open-uri'
require 'cgi'

class RemoteModel
  AttributeTypeMismatch = Class.new(StandardError)

  class << self
    attr_accessor :site, :element_xpath
    
    private
    
    def renamed_arguments
      @renamed_arguments ||= {}
    end

    def mapped_arguments
      @mapped_arguments ||= {}
    end

    def default_arguments
      @default_arguments ||= {}
    end

    def fields
      @fields ||= {}
    end
    
    def content_sanitizers
      @content_sanitizers ||= []
    end
  end

  def self.host
    URI.split(site).values_at(0, 2).join('://') if site
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

  def initialize(attributes = {})
    attributes.each do |k, v|
      send("#{k}=", v)
    end
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
    
    args = default_arguments.merge(args)
    
    args.dup.each do |k, v|
      argument = k.to_sym
      mapped_argument = mapped_arguments[argument]
      args[argument] = mapped_argument.call(v) if mapped_argument
      renamed_argument = renamed_arguments[argument]
      args[renamed_argument] = args[argument] and args.delete(argument) if renamed_argument
    end
    
    url = site.gsub(/((:\w+)|\*)/) do |match|
      args.delete(match[1..-1].to_sym)
    end
    
    query = args.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&') unless args.empty?
    contents  = open([url, query].compact.join('?')) { |f| f.read }
    content_sanitizers.each { |c| contents = c.call(contents) }
    
    doc = Nokogiri::HTML(contents) do |config|
      config.noerror
    end
    
    return [] unless doc
    
    doc.xpath(element_xpath).map do |e|
      model = self.new
      model.initialize_with_element(e)
      model
    end
  end
end