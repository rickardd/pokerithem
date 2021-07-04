require_relative "../app/player.rb" 
require_relative "../app/virtual_player_interface.rb"

class Eleanor < Player
    # write rspec test to ensure this is correctly implemented. 
    include VirtualPlayerInterface

    def initialize
        super("Eleanor") 
    end
   
    # Write an algorith which finally will call the method add_action(action, chip) e.g
    # add_action("fold") if fold, the value will default to zero anyway
    # add_action("call") will default to the same chips as the first previous player that did not fold
    # add_action("raise", x) if fold, the value will default to zero anyway
    
    def do_action snapshot
        # HERE GOES YOUR ALGORITHM. 

        puts
        puts "------VIRTUAL PLAYER DATA--------"
        puts "v-player: NAME #{name}"
        puts "v-player: CARDS #{cards}"
        puts "v-player: REMAINING MONEY #{remaining_money}"
        puts "last_round_actions: #{snapshot.last_round_actions}"
        puts "total_biddings: #{snapshot.total_biddings}"
        puts "current_bet: #{snapshot.current_bet}"
        puts "total_players: #{snapshot.total_players}"
        puts "Table: cards: #{snapshot.cards_on_table}"
        puts "----------------------------"
        puts

        action = ["fold", "call", "call", "call", "call",  "call",  "call", "raise", "raise", "raise"].shuffle.first

        if action == "raise"
            add_action action, 20 # algorithm decision
            return
        end

        add_action action
    end
end