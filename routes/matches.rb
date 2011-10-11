require 'models/match'

module Application
  class Application < Sinatra::Base
    get '/matches' do
      content_type :json
      Match.find(:page => params[:page].to_i, :game => params[:game]).to_json
    end
  end
end