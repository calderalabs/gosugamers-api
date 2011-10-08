require 'rest_client'
require 'parse/request'

module Parse
  class Notification 
    attr_accessor :type, :channels, :alert, :badge, :sound, :custom_data
    
    def self.push!(options = {})
      new(options).push!
    end
    
    def initialize(options = {})
      @type = options[:type]
      @channels = [*options[:channels]]
      
      @alert = options[:alert]
      @badge = options[:badge]
      @sound = options[:sound]
      @custom_data = options[:custom_data] || {}
    end
    
    def push!
      @channels.each do |channel|
        Parse::Request.execute!('push', :post,
          {
            :key => Parse::Request.master_key,
            :type => @type,
            :channel => channel,
            :data => {
              :alert => @alert,
              :badge => @badge,
              :sound => @sound
            }.merge(@custom_data)
          }
        )
      end
    end
  end
end