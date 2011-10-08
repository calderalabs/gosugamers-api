require 'models/news'

module Application
  class Application < Sinatra::Base
    get '/news' do
      content_type :json
      News.find(:page => params[:page], :game => params[:game]).to_json
    end
  end
end