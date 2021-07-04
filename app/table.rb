require_relative "chipSet.rb"
require_relative "hand.rb"

class Table 
    attr_reader :hand

    def initialize
        @hand = Hand.new
        @chip_pool = ChipSet.new # This is the pool. All players chips moves to here before dealer adds more cards to the table.
    end
end