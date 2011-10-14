module Synchronizable
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def synchronizable_on(*games)
      @games = *games
      extend SingletonMethods
    end
  end
  
  module SingletonMethods
    def synchronize!
      @games.each do |game|
        key = "last_#{name.downcase}_#{game}"
        last_obj_s = $redis.get(key)
        objects = find(:page => 1, :game => game)
        $redis.set(key, { :id => objects.max{ |a, b| a.id <=> b.id }.id }.to_json)
        next unless last_obj_s
        last_obj = JSON.parse(last_obj_s)
        objects.keep_if { |o| o.id > last_obj['id'] }.each { |o| o.to_notification.push! }
      end
    end
  end
end