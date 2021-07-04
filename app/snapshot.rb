# require_relative "helper.rb"

class Snapshot
    def initialize players, current_player, table, played_rounds
        @players = players
        @table = table
        @played_rounds = played_rounds
        @current_player = current_player
    end

    def last_round_actions
        @players
            .reject {|player| player.actions.count <= no_of_completed_rounds }
            .map {|player| player.actions.last }
    end
    
    def current_bet
        opponents = Helper.opponents @players, @current_player
        remaining_opponents = opponents.reject {|player| player.out_of_game }

        if remaining_opponents.last
            remaining_opponents.last.chips.get.last
        end
    end
    
    def total_biddings
        @players.map { |player| player.chips.get.sum }.sum
    end

    def cards_on_table
        @table.hand.cards
    end

    def total_players
        @players.count
    end

    private

    def no_of_completed_rounds
        @players.map {|player| player.actions.count }.min
    end
end