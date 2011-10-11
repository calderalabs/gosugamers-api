require 'models/replay'

module Application
  class Application < Sinatra::Base
    get '/replays' do
      content_type :json
      Replay.find(:page => params[:page].to_i, :game => params[:game]).to_json
    end
  end
end