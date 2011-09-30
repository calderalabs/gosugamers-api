require 'open-uri'
require 'cgi'

class RemoteModel
  class << self
    attr_accessor :site
  end

  attr_accessor :id

  def initialize(attributes = {})
    attributes.each do |k, v|
      send("#{k}=", v)
    end
  end

  def self.find_from_site(site, args = nil)
    query = args.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&') if args
    contents  = open([site, query].compact.join('?')) { |f| f.read }
    extract_from_contents(contents)
  end
  
  def self.find(args = nil)
    find_from_site(site, args)
  end
  
  def self.extract_from_contents(contents)
    nil
  end
end