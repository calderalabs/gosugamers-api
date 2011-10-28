require 'models/news'
require 'models/match'
require 'models/replay'

class Synchronize
    def self.perform
        News.synchronize!
        Match.synchronize!
        Replay.synchronize!
    end
end