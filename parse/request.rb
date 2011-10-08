require 'rest-client'

module Parse
  class Request
    class << self
      attr_accessor :application_id, :master_key
    end
    
    attr_accessor :path, :method, :args
    
    def self.execute!(path, method = :get, args = {})
      new(path, method, args).execute!
    end
    
    def initialize(path, method = :get, args = {})
      @path = path
      @method = method
      @args = args
    end
    
    def execute!(&block)
      RestClient::Request.execute(
        :method => @method,
        :url => "https://#{self.class.application_id}:#{self.class.master_key}@api.parse.com/1/#{@path}",
        :payload => @args.to_json,
        :headers => {
          :content_type => :json,
          :accept => :json
        }
      ) do |response, request, result|
        block.call(response.code, JSON.parse(response.body)) if block
      end
    end
  end
end