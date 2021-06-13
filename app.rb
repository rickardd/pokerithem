require_relative "validator.rb" 

# 1. if only 2 players. If one folds the other player wins
# 2. if more than 2 players. we have to ask remianing players for action before moving to flop-round
# 3. - Don't move to next round until no one is raising. 

class Game 
    attr_reader :heighest_bet_total

    AUTOMATIC_BIG_BLIND_BET = 20
    AUTOMATIC_SMALL_BLIND_BET = 10
    ACTION_LIMIT = 10

    def initialize
        @players = []
        @dealer = Dealer.new
        @table = Table.new
        @played_rounds = RoundTracker.new
        @validator = Validator.new
    end
    
    def add_player player
        @players << player
    end

    def start 
        puts "Dealing 2 cards to each player..."
        puts
        # Deal 2 to each player
        deal_2_to_each_player
        
        puts "Player 1 has to 'bet' as small blind..."
        # The small blind player will automatically bet 10 chips
        add_chips_to_small_blind
        puts "#{@players[0].name}'s chips (small blind) : #{@players[0].chips.get}"
        puts

        puts "Player 2 has to 'bet' as big blind..."
        # The big blind player will automatically bet 20 chips.
        add_chips_to_big_blind
        puts "#{@players[1].name}'s chips (big blind) : #{@players[1].chips.get}"
        puts

        # to be implemented
        # ask remaining players for actions. Same as do_next but without small- and big-blind

        new_round

        # Update the Table.Chip class with the new chips if any. 
    end

    def heighest_bet_total
        @players.map { |player| player.chips.get.sum}.max
    end

    def deal_2_to_each_player
        @players.each do |player|
            @dealer.deal player, 2
            puts "#{player.name}'s cards #{player.hand.look_at_cards}"
            puts
        end
    end
    
    def add_chips_to_small_blind
        @players[0].chips.add_chip AUTOMATIC_SMALL_BLIND_BET
    end

    def add_chips_to_big_blind
        @players[1].chips.add_chip AUTOMATIC_BIG_BLIND_BET
    end

    def chips_total
        @players.map { |player| player.chips.sum }.sum        
    end
    
    def number_of_completed_rounds
        @players.last.actions.length
    end

    def ask_players_for_action 
        @players.each do |player|
            #Players how has folded will still be asked for the record. This could be a subject for refactoring. 
            is_out_of_game = player.out_of_game # saves the value before this round
            
            data = {
                current_bet: heighest_bet_total,
                oponents: @players.reject { |p| p.name == player.name }.map { |p| { chips: p.chips, actions: p.actions }.to_h },
                cards_on_table: @table.hand.cards,
                chips_total: chips_total,
                number_of_completed_rounds: number_of_completed_rounds
            }.to_h

            player.do_action data
            
            # needs to check if this bet is higher than the previous heighest bet if player is raising. 
            if is_out_of_game
                puts player.name + " is out of the game"
            else
                puts player.name + " decided to " + player.actions.last + " by " + player.chips.get.last.to_s + " chips"
            end
            puts
        end

        if any_player_raised? && number_of_remaining_players > 1
            ask_players_for_action
        else
            puts "-- SET NEXT ROUND"
            puts
            @played_rounds.set_next
        end

        # what happens if every player decides to fold?
    end

    def number_of_remaining_players
        @players.reject { |player| player.out_of_game }.length
    end

    def last_remaining_player
        remaining_players = @players.reject { |player| player.out_of_game }
        
        if remaining_players.length == 1
            remaining_players.first
        else
            raise "There are #{remaining_players.length} remaining players, expected 1 remaining player"
        end
            
    end

    def any_player_raised?
        @players.map { |player| player.actions.last }.include? "raise"
    end

    def action_limit_reached?
        @players.last.actions.length > ACTION_LIMIT
    end

    def end_of_game?
        puts "END OF GAME? #{@played_rounds.current == "end" || number_of_remaining_players < 2}"
        @played_rounds.current == "end" || number_of_remaining_players < 2
    end

    # player hand plus table hand
    def full_hand player
        if @table.hand.cards.first
            return @table.hand.cards.first + player.hand.cards.first            
        end

        player.hand.cards.first
    end

    def declare_a_winner
        # players = @players.select { |player| !player.out_of_game }
        current_round_players = @players.reject { |player| player.actions.last == "-" } # excludes players which was out(folded) before this round started. 

        # puts "XXXX----- #{@players.map &:actions}"
        players_who_did_not_fold = current_round_players.reject { |player| player.actions.last == "fold" }

        puts "++++++++++++++++ curent_players = #{current_round_players.length} folded_players = #{players_who_did_not_fold.length}"

        if current_round_players.length == 1
            player = current_round_players.first
            ranking = @validator.validate(full_hand(player))
            return {
                name: player.name, 
                ranking_name: ranking[:name], # e.g "royal flush"
                ranking_value: ranking[:value], # e.g 10
                sum: ranking[:sum] # total sum of hand
            }.to_h
        elsif players_who_did_not_fold.length == 0
            # If everyone folded, the winner is the player after the one who folded first. In ohter words the second player. 
            player = current_round_players[1]
            ranking = @validator.validate(full_hand(player))
            return {
                name: player.name, 
                ranking_name: ranking[:name], # e.g "royal flush"
                ranking_value: ranking[:value], # e.g 10
                sum: ranking[:sum] # total sum of hand
            }.to_h
        elsif players_who_did_not_fold.length == 1
            # If only one player who didn't fold the last round
            player = players_who_did_not_fold.first  
            ranking = @validator.validate(full_hand(player))
            return {
                name: player.name, 
                ranking_name: ranking[:name], # e.g "royal flush"
                ranking_value: ranking[:value], # e.g 10
                sum: ranking[:sum] # total sum of hand
            }.to_h
        else
            # puts "----------------------------ANY PLAYER #{players_who_did_not_fold}"

            # 1. Create a new array of hashes e.g { name: "Rob", ranking_name: "royal_flush", ranking_value: 10, sum: 10 [the total sum of cards] }
            player_summary_hash = players_who_did_not_fold.map do |player| 
                ranking = @validator.validate(full_hand(player))
                {
                    name: player.name, 
                    ranking_name: ranking[:name], # e.g "royal flush"
                    ranking_value: ranking[:value], # e.g 10
                    sum: ranking[:sum] # total sum of hand
                }.to_h
                # 2. Sort by highest ranking and sum
                player_summary_hash = player_summary_hash.sort_by { |a| [ a[:ranking_value], a[:sum] ] }.reverse
                # 3. The first hash is the winner
                return player_summary_hash.first
            end
        end
        
    end
    
    def new_round

        if end_of_game?
            puts
            puts "END OF GAME"
            puts
            winner = declare_a_winner
            puts "Declaring a winner..."
            puts
            puts "The winner is... #{winner[:name]} with #{winner[:ranking_name]} (#{winner[:ranking_value]} points) and a sum of #{winner[:sum]}"
        else

            puts "New round (#{@played_rounds.current})..."
            puts

            deal_to_table

            puts "The Table has #{@table.hand.look_at_cards}"
            puts 

            ask_players_for_action # ask each player to fold, call or raise
            
            new_round
        end 
    end

    def deal_to_table
        if @played_rounds.current == "flop"
            puts "Dealing 3 cards to the Table..."
            @dealer.deal @table, 3
        elsif @played_rounds.current == "turn"
            puts "Dealing 1 more card to the Table..."
            @dealer.deal @table, 1
        elsif @played_rounds.current == "river"
            puts "Dealing 1 more card to the Table..."
            @dealer.deal @table, 1
        end
    end

    def new_game
        # set the big blind player. the player to the "left" of the dealer
        rotate_players
    end

    # Sets the new big blind player at the beginning of the players array.
    def rotate_players
        @players.rotate!(1)        
    end
end

class RoundTracker
    attr_reader :pre_flop, :flop, :turn, :river

    def initialize
        @pre_flop = true # 0 cards on the table
        @flop = false # 3 cards on the table
        @turn = false # 4 cards on the table
        @river = false # 5 cards on the table
        @end = false # end of rounds
    end

    def set_next
        if !@pre_flop
            @pre_flop = true
        elsif !@flop
            @flop = true
        elsif !@turn
            @turn = true
        elsif !@river
            @river = true
        elsif !@end
            @end = true
        end
    end

    def current
        return "end" if @end
        return "river" if @river
        return "turn" if @turn
        return "flop" if @flop
        return "pre flop"
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
        # puts "delt " + cards.to_s +  " to " + entity.name
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
        @wallet = 50
    end

    def add_chip number
        if @wallet - number <= 0
            # puts "OUT OF MONEY MATE!"
            return false
        end
        @wallet -= number
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

    def sum 
        @chips.sum
    end
end

class Player 
    attr_accessor :out_of_game
    attr_reader :name, :score, :hand, :chips, :actions
    
    def initialize name
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
        @actions.any? { |action| ["fold", "-"].include? action }
    end

    protected

    def add_action action, *chip
        chip = chip.first
        raise "No action defined" if action.empty?
        raise "You decided to raise but defined no bet" if actions == "raise" && chip.empty?
        # implement this
        #raise "Raise is not heigh enough" if game.heighest_bet_total < @chips.get.sum + chip

        # puts "rick" + heighest_bet_total.to_s

        # puts "---------" + game.heighest_bet_total # how to acces this?

        action = "-" if @actions.include? "fold"

        chip = -1 if action == "-"
        chip = 0 if action == "fold"
        chip = 10 if action == "call" # update this to be the same as previous maximum bid. (game.heighest_bet_total - this players total)

        @actions <<  action
        
        last_bet = @chips.add_chip chip

        if !last_bet
            puts "(#{name} IS OUT OF MONEY)"
        end
    end
    
end

class Table 
    attr_reader :hand

    def initialize
        @hand = Hand.new
        @chip_pool = ChipSet.new # This is the pool. All players chips moves to here before dealer adds more cards to the table.
    end
end

class Hand 
    attr_reader :cards

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
    # write rspec test to ensure this is correctly implemented. 
    include VirtualPlayerInterface
   
    # Write an algorith which finally will call the method add_action(action, chip) e.g
    # add_action("fold") if fold, the value will default to zero anyway
    # add_action("call") will default to the same chips as the first previous player that did not fold
    # add_action("raise", x) if fold, the value will default to zero anyway
    
    def do_action data
        # HERE GOES YOUR ALGORITHM. 
        
        # Need to know 
        # other players actions
        # other players bets
        # cards on the table
        # how many rounds has it been. 
        # number of chips on the table
        
        # Available attributes
        # @hand
        # @chips
        # @actions
        # I'm playe x of y. e.g I'm player 3 of 4 so I know how many after is to play. 

        # puts "VP: current_bet " + data[:current_bet].to_s
        # data[:oponents].each_with_index { |o, i| puts "Oponent: #{i} #{o[:chips].get}" }
        # puts "VP: cards_on_table " + data[:cards_on_table].to_s
        # puts "VP: chips_total " + data[:chips_total].to_s
        # puts "VP: chips_in_pool " + data[:chips_in_pool].to_s
        # puts "VP: number_of_completed_rounds " + data[:number_of_completed_rounds].to_s

        if data[:current_bet] > 50
            action = "call"
            puts "(#{name} is bailing cause current bet is above 50)"
            puts
        else
            action = ["fold", "call", "raise"].shuffle.first
        end

        if action == "raise"
            add_action action, 20 # algorithm decision
            return
        end

        add_action action
    end
end

game = Game.new

game.add_player VirtualPlayer.new "Rob"
game.add_player VirtualPlayer.new "Kriszta"

game.start
# game.next
# game.next


# validator = Validator.new
# puts validator.validate([[2, 2], [3, 1], [4, 1], [10, 1], [11, 1]])

# puts "deck ---"
# deck = Deck.new
# puts deck.take 2

