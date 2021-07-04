require "pry"
require_relative "app/game.rb"

game = Game.new
game.start

puts
puts
puts game.get_json
