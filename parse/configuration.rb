module Parse
  class Configuration
    def self.configure
      c = new
      yield(c)
      c.configure!
    end
    
    attr_accessor :master_key, :application_id
    
    def configure!
      Parse::Request.master_key = master_key
      Parse::Request.application_id = application_id
    end
  end
end