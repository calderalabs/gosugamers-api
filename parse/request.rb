require 'rest-client'

module Parse
  class Request
    ConfigurationError = Class.new(StandardError)
    
    class << self
      attr_accessor :application_id, :master_key
    end
    
    attr_accessor :path, :method, :args
    
    def self.execute!(path, method = :get, args = {})
      new(path, method, args).execute!
    end
    
    def initialize(path, method = :get, args = {})
      @path = path or raise ArgumentError, "no path specified"
      @method = method
      @args = args
    end
    
    def execute!
      raise ConfigurationError, "you must provide a master key" unless self.class.master_key
      raise ConfigurationError, "you must provide an application id" unless self.class.application_id
      
      JSON.parse(RestClient::Request.execute(
        :method => @method,
        :url => "https://#{self.class.application_id}:#{self.class.master_key}@api.parse.com/1/#{@path}",
        :payload => @args.to_json,
        :headers => {
          :content_type => :json,
          :accept => :json
        }
      ).body)
    end
  end
end