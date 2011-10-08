require 'rest_client'
require 'parse/request'

module Parse
  class Notification 
    attr_accessor :type, :channels, :alert, :badge, :sound, :custom_data
    
    def initialize(options = {})
      @type = options[:type]
      @channels = options[:channels]
      
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
    
    def +(other)
      self.class.new(
        :badge => @badge + other.badge,
        :channels => @channels & other.channels,
        :alert => [@alert, other.alert].join('\n\n')
      )
    end
  end
end

class Array
  def to_notification
    return nil if empty?
    
    inject(Parse::Notification.new) do |notification, e|
      notification += e.to_notification
    end
  end
end