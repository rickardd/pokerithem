require 'sinatra'
require_relative './app.rb'

Tilt.register Tilt::ERBTemplate, 'html.erb'

get '/' do

    game = Game.new
    game.start
    data = game.get_json
    result = game.result

    erb :index, locals: { data: data, result: result, helper: Helper.new }
      
end