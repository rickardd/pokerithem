class Snapshot
    def initialize players, table, played_rounds
        @players = players
        @table = table
        @played_rounds = played_rounds
    end

    def last_round_actions
        @players
            .reject {|player| player.actions.count <= no_of_completed_rounds }
            .map {|player| player.actions.last }
    end
    
    def current_bet
        @players.reject {|player| player.out_of_game }.last.chips.get.last
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