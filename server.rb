require 'sinatra'
require_relative './app.rb'

Tilt.register Tilt::ERBTemplate, 'html.erb'

get '/' do

    game = Game.new

    game.add_player VirtualPlayer.new "Rob"
    game.add_player VirtualPlayer.new "Kriszta"

    game.start
    data = game.get_json

    erb :index, locals: { data: data, helper: Helper.new }
      
end