require 'models/news'

module Application
  class Application < Sinatra::Base
    get '/news' do
      content_type :json
    end
  end
end