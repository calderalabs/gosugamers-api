require 'open-uri'
require 'cgi'

class RemoteModel
  AttributeTypeMismatch = Class.new(StandardError)
  
  class << self
    attr_accessor :site, :element_xpath
  end
  
  def self.host
    URI.split(site).values_at(0, 2).join('://')
  end
  
  def self.renamed_arguments
    @renamed_arguments ||= {}
  end
  
  def self.mapped_arguments
    @mapped_arguments ||= {}
  end
  
  def self.fields
    @fields ||= {}
  end

  def self.field(field, type)
    fields[field] = type
    
    class_eval <<-EOT
      def #{field}
        @#{field}
      end
      
      def #{field}=(val)
        raise AttributeTypeMismatch, "\#{val.class.name} \#{val} cannot be assigned to \
        \#{self.class.fields[:#{field}].class.name} \field #{field}" unless val.is_a?(self.class.fields[:#{field}])
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
    renamed_arguments[argument] = new_name
  end
  
  def self.map_argument(argument, &block)
    mapped_arguments[argument] = block
  end

  def self.replace_argument(argument, new_name, &block)
    rename_argument(argument, new_name)
    map_argument(argument) { block }
  end

  def self.default_argument(argument, val)
    map_argument(argument) { |a| a || val }
  end

  def self.find(args = {})
    args.dup do |k, v|
      mapped_argument = mapped_arguments[k]
      args[k] = mapped_argument.call(v) if mapped_argument
      renamed_argument = renamed_arguments[k]
      args.delete(:k) and args[renamed_argument] = args[k] if renamed_argument
    end
    
    url = site
    url.gsub!(/((:\w+)|\*)/) do |match|
      args.delete(match[1..-1].to_sym)
    end
    
    query = args.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&') unless args.empty?
    contents  = open([url, query].compact.join('?')) { |f| f.read }
    
    doc = Nokogiri::HTML(contents) do |config|
      config.noerror
    end
    
    doc.xpath(element_xpath).map do |e|
      model = self.new
      model.initialize_with_element(e)
      model
    end
  end
end