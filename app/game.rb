require_relative "validator.rb" 
require_relative "deck.rb"
require_relative "round_tracker.rb"
require_relative "table.rb"
require_relative "dealer.rb"
require_relative "helper.rb"
require_relative "record.rb"
require_relative "snapshot.rb"

require_relative "../players/rob.rb" 
require_relative "../players/kriszta.rb" 
require_relative "../players/frank.rb" 
require_relative "../players/eleanor.rb" 


# 1. if only 2 players. If one folds the other player wins
# 2. if more than 2 players. we have to ask remaining players for action before moving to flop-round
# 3. - Don't move to next round until no one is raising. 

class Game 
    attr_reader :highest_bet_total

    AUTOMATIC_BIG_BLIND_BET = 20
    AUTOMATIC_SMALL_BLIND_BET = 10
    ACTION_LIMIT = 10

    def initialize
        @players = []
        @dealer = Dealer.new
        @table = Table.new
        @played_rounds = RoundTracker.new
        @validator = Validator.new
        @records = Record.new
        @winner = nil
    end
    
    def start 
        add_players
        set_up_first_round
        new_round
    end

    def add_players 
        add_player Rob.new
        add_player Kriszta.new
        add_player Frank.new
        add_player Eleanor.new
    end
    
    def add_player player
        @players << player
        @records.add "Add player", { player: player.name }
    end

    
    def set_up_first_round
        @records.add "Deal 2 cards to each player"
        deal_2_to_each_player
        
        @records.add "Add small blind bet", {player: @players[0].name }
        # The small blind player will automatically bet 10 chips
        add_chips_to_small_blind
        @records.add "Show chips", { extra: "small blind", player: @players[0].name, chips: @players[0].chips.get }
        
        @records.add "Add big blind bet", { player: @players[1].name }
        # The big blind player will automatically bet 20 chips.
        add_chips_to_big_blind
        @records.add "Show chips", { extra: "big blind", player: @players[1].name, chips: @players[1].chips.get }

        # to be implemented
        # ask remaining players for actions. Same as do_next but without small- and big-blind
        
    end

    def new_round
        if end_of_game?
            @records.add "END OF GAME"
            @winner = declare_a_winner
            @records.add "Winner", { player: @winner[:name], ranking_name: @winner[:ranking_name], ranking_value: @winner[:ranking_value], sum: @winner[:sum] }
        else
            @records.add "New round", { round: @played_rounds.current }
            deal_to_table
            @records.add "Show table cards", { cards: @table.hand.get }
            ask_players_for_action # ask each player to fold, call or raise
            new_round
        end 
    end

    def highest_bet_total
        @players.map { |player| player.chips.get.sum}.max
    end

    def deal_2_to_each_player
        @players.each do |player|
            @dealer.deal player, 2
            @records.add "Show player cards", {player: player.name, cards: player.hand.cards }
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
            snapshot = Snapshot.new(@players, player, @table, @played_rounds) #consider passing in self. 
            successful_action = player.do_action snapshot 
            
            #Players how has folded will still be asked for the record. This could be a subject for refactoring. 
            is_out_of_game = player.out_of_game # saves the value before this round   
            
            # needs to check if this bet is higher than the previous highest bet if player is raising. 
            if is_out_of_game
                @records.add "Game over player", player.name
            else
                if !successful_action
                    # This means the player has been forced another action due to lack of money e.g 
                    # - raise 10 chips if only 5 in wallet will result in a fold if earlier current bid is higher than 5. 
                    # - raising by 20 chips if only 10 in wallet will result in a call if current bid is 10
                    @records.add "Out of money", { player: player.name, wallet: player.chips.wallet, all_chips: player.chips.get }
                end
                @records.add "Player decision", {player: player.name, decision: player.actions.last, all_chips: player.chips.get, last_chip: player.chips.get.last, chips_sum: player.chips.sum, wallet: player.chips.wallet }
            end
        end

        if any_player_raised? && number_of_remaining_players > 1
            ask_players_for_action
        else
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
        @played_rounds.current == "end" || number_of_remaining_players < 2
    end

    # player hand plus table hand
    def full_hand player
        if @table.hand.cards.any?
            return @table.hand.cards.first + player.hand.cards.first            
        end
        player.hand.cards.first
    end

    def players_in_current_round
        @players.reject { |player| player.actions.last == "-" } # excludes players which was out(folded) before this round started. 
    end

    def get_players_who_did_not_fold players
        players.reject { |player| player.actions.last == "fold" }
    end
    
    def winner_result_hash player
        ranking = @validator.validate(full_hand(player))
        {
            name: player.name, 
            ranking_name: ranking[:name], # e.g "royal flush"
            ranking_value: ranking[:value], # e.g 10
            sum: ranking[:sum] # total sum of hand
        }.to_h
    end

    def declare_a_winner
        current_players = players_in_current_round
        players_who_did_not_fold = get_players_who_did_not_fold current_players

        if current_players.length == 1
            player = current_players.first
            winner_result_hash player
        elsif players_who_did_not_fold.length == 0
            # If everyone folded, the winner is the player after the one who folded first. In ohter words the second player. 
            player = current_players[1]
            winner_result_hash player
        elsif players_who_did_not_fold.length == 1
            # If only one player who didn't fold the last round
            player = players_who_did_not_fold.first  
            winner_result_hash player
        else
            # 1. Create a new array of hashes e.g { name: "Rob", ranking_name: "royal_flush", ranking_value: 10, sum: 10 [the total sum of cards] }
            player_summary_hash = players_who_did_not_fold.map { |player| winner_result_hash player }
            # 2. Sort by highest ranking and sum
            player_summary_hash.sort_by! { |a| [ a[:ranking_value], a[:sum] ] }.reverse
            # 3. The first hash is the winner
            player_summary_hash.first
        end
    end

    def deal_to_table
        if @played_rounds.current == "flop"
            @records.add "Deal 3 cards to the Table..."
            @dealer.deal @table, 3
        elsif @played_rounds.current == "turn"
            @records.add "Deal 1 more card to the Table..."
            @dealer.deal @table, 1
        elsif @played_rounds.current == "river"
            @records.add "Deal 1 more card to the Table..."
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

    def get_json
        puts @records.get_json
        @records.get_json
    end

    def result
        {
            players: @players,
            table: @table,
            winner: @winner,
        }
    end
end