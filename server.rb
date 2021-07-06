require 'sinatra'
require_relative './app.rb'

Tilt.register Tilt::ERBTemplate, 'html.erb'

get '/' do

    game = Game.new
    game.start
    data = game.get_json
    result = game.result

    # session[:session_winners] = ["Kriszta", "Kriszta", "Rob", "Kriszta"]
    session[:session_winners] = [] if !session[:session_winners]
    session[:session_winners] << result[:winner][:name]

    session_winners = session[:session_winners].uniq.map do |name| 
        { 
            name: name, 
            count: session[:session_winners].select {|n| n == name }.length 
        }.to_h 
    end
    
    erb :index, locals: { data: data, result: result, helper: Helper.new, session_winners: session_winners }
      
end