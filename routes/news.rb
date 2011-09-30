require 'models/news'

module Routes
  class Application < Sinatra::Base
    get '/news' do
      content_type :json
    end
  end
end