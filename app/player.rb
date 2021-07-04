require_relative "chipSet.rb"
require_relative "hand.rb"

class Player
    attr_accessor :out_of_game
    attr_reader :name, :score, :hand, :chips, :actions
    
    def initialize name = "Name needs to be set"
        @name = name
        @score = 0
        @hand = Hand.new
        @chips = ChipSet.new
        @actions = []
    end
    
    def display_all
        puts "Name: #{@name}"
        puts "Score: #{@score}"
        puts "Cards: #{@hand.look_at_cards}"
    end

    def out_of_game
        @actions.any? { |action| ["fold", "-"].include? action } || @chips.wallet <= 0
    end

    protected

    def add_action action, *chip
        chip = chip.first
        # raise "No action defined" if action.empty?
        # raise "You decided to raise but defined no bet" if action == "raise" && chip.empty?
        # implement this
        #raise "Raise is not heigh enough" if game.highest_bet_total < @chips.get.sum + chip
        action = "-" if @actions.include? "fold"
        
        bid_greater_than_wallet = chip && @chips.wallet < chip
        
        chip = -1 if action == "-"
        chip = 0 if action == "fold"
        chip = 10 if action == "call" # update this to be the same as previous maximum bid. (game.highest_bet_total - this players total)
        chip = @chips.wallet  if action == "raise" && bid_greater_than_wallet # sets chip to remaining many the player has if betting too high. 
        # Make sure player has enough money if the do a call. 

        action = "fold" if chip.between?(0, 9) # 10 has to be updated to previous players bet. 
        action = "call" if chip == 10

        @chips.add_chip chip

        @actions <<  action

        !bid_greater_than_wallet # Returns false if attempted bid was greater than the money left in the wallet, else true
    end

    def remaining_money
        @chips.wallet
    end
    
    def cards
        @hand.cards
    end
    
end