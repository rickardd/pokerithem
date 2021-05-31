require_relative "validator.rb" 

# 1. - Deck: Make  @cards a 2 dimentional array with correct values (52)
# 2. - Deck: Create method take_n_cards
# 3. - Table: create this class which has a hand just like the Player class. 
# 4. Dealer: new methods deal_2_cards_to_each_player, deal_3_cards_to_table, deal_1_cards_to_table
# 5. Validator: add sum method
# 6. Validator: compare hands
# 7. Game: create a game loop to call next each x second.
# 8. Ensure validator handles ais 14 as 1 as well. 

class Game 

    AUTOMATIC_BIG_BLIND_BET = 20
    AUTOMATIC_SMALL_BLIND_BET = 10
    ACTION_LIMIT = 10

    def initialize
        @players = []
        @dealer = Dealer.new
        @table = Table.new
    end
    
    def add_player player
        @players << player
    end

    def start 
        # Deal 2 to each player
        deal_2_to_each_player
        # The big blind player will automatically bet 20 chips.
        add_chips_to_big_blind
        puts "Player 1 chips: " + @players[0].chips.get.to_s
        # The small blind player will automatically bet 10 chips
        add_chips_to_small_blind
        puts "Player 2 chips: " + @players[1].chips.get.to_s

        do_next
        # Ask player 3 if raise, call or fold
        # Update the Table.Chip class with the new chips if any. 
    end

    def deal_2_to_each_player
        @players.each do |player|
            puts player.name
            @dealer.deal player, 2
            puts
        end
    end

    def add_chips_to_big_blind
        @players[0].chips.add_chip AUTOMATIC_BIG_BLIND_BET
    end
    
    def add_chips_to_small_blind
        @players[1].chips.add_chip AUTOMATIC_SMALL_BLIND_BET
    end

    def ask_players_for_action
        @players.each do |player|
            player.do_action
            puts player.name + " decided to " + player.actions.last + " by " + player.chips.get.last.to_s + " chips"
        end
        # what happens if every player decides to fold?

    end

    def any_player_raised?
        @players.map { |player| player.actions.last }.include? "raise"
    end

    def action_limit_reached?
        @players.last.actions.length > ACTION_LIMIT
    end
    
    def do_next
        puts
        puts "....dealing"
        puts

        # ask each player to fold, call or raise
        ask_players_for_action
        
        if any_player_raised?
            puts "next round"
            if action_limit_reached?
                return puts "ERROR. LIMIT OF ROUNDS (#{ACTION_LIMIT}) HAS BEEN REACHED. Tweak algorithms to be less agressive with raising."
            end
            
            do_next 
        else
            puts
            puts "Move all chips to the pool"
        end
    end

    def new_round
        # set the big blind player. the player to the "left" of the dealer
        rotate_players
    end

    # Sets the new big blind player at the beginning of the players array.
    def rotate_players
        @players.rotate!(1)        
    end
end

class Dealer
    def initialize
        @deck = Deck.new
    end
    
    # entity table or player
    def deal entity, number
        cards = @deck.take number
        entity.hand.add cards
        puts "delt " + cards.to_s +  " to " + entity.name
        return cards
    end
end

class Deck 
    
    def initialize
        @cards = generate_deck
    end
    
    def take number
        if @cards.empty?
           return puts "deck is out" 
        end

        to_index = number - 1
        @cards.slice! 0..to_index
    end

    private

    def generate_deck
        (1..14).flat_map { |number| (1..4).map { |color| [number, color] } }.shuffle
    end
end

class ChipSet 

    def initialize
        @chips = []
    end

    def add_chip number
        @chips << number
    end

    def get_and_empty 
        existing_chips = @chips
        @chips.clear
        existing_chips
    end
    
    def get 
        @chips
    end
end

class Player 
    #attr_accessor :hand
    attr_reader :name, :score, :tokens, :hand, :chips, :actions
    
    def initialize name
        @name = name
        @score = 0
        @tokens = 0
        @hand = Hand.new
        @chips = ChipSet.new
        @actions = []
    end
    
    def display_all
        puts "Name: #{@name}"
        puts "Score: #{@score}"
        puts "Tokens: #{@tokens}"
        puts "Cards: #{@hand.look_at_cards}"
    end

    #move to VertualPlayer
    def do_action
        # temp code
        @actions <<  ["fold", "call", "raise"].shuffle.first

        if @actions.last == "fold"
            @chips.add_chip 0
        end

        if @actions.last == "call"
            @chips.add_chip 10 # algorithm decision
        end
        
        if @actions.last == "raise"
            @chips.add_chip 20 # algorithm decision
        end
        
    end
end

class Table 
    def initialize
        @hand = Hand.new
        @chip_pool = ChipSet.new # This is the pool. All players chips moves to here before dealer adds more cards to the table.
    end
end

class Hand 
    def initialize
        @cards = []
    end
    
    def look_at_cards
        return @cards.to_s
        #@cards.each { |card| print card } 
    end
    
    def add cards
        @cards << cards
    end
end

module VirtualPlayerInterface
    def do_action
        raise "Not implemented"
    end  
end

# should this be an interface or extend.. or both?
class VirtualPlayer < Player
    include VirtualPlayerInterface
   
   # needs access to 
   # @hand
   # number of rounds
   # number of tokens on the table
   # I'm playe x of y. e.g I'm player 3 of 4 so I know how many after is to play. 
   
    # Write Algorithm
    # def raise_bid 
        
    # end
    
    # Write Algorithm
    # def pass 
        
    # end

    def do_action

    end
    
end

game = Game.new

game.add_player Player.new "Rob"
game.add_player Player.new "Kriszta"

game.start
# game.next
# game.next


# validator = Validator.new
# puts validator.validate([[2, 2], [3, 1], [4, 1], [10, 1], [11, 1]])

# puts "deck ---"
# deck = Deck.new
# puts deck.take 2



