require_relative "../app/player.rb" 
require_relative "../app/virtual_player_interface.rb"

class Kriszta < Player
    # write rspec test to ensure this is correctly implemented. 
    include VirtualPlayerInterface

    def initialize
        super("Kriszta") 
        @round_counter = 0
    end
   
    # Write an algorithm which finally will call the method add_action(action, chip) e.g
    # add_action("fold") if fold, the value will default to zero anyway
    # add_action("call") will default to the same chips as the first previous player that did not fold
    # add_action("raise", x) if fold, the value will default to zero anyway
    
    def do_action snapshot

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

        if snapshot.cards_on_table.any?
            @all_cards = snapshot.cards_on_table[0] + cards
        end

        # Maybe this should be part of the Player class
        pre_flop snapshot if snapshot.current_round == "pre flop"
        flop snapshot if snapshot.current_round == "flop"
        turn snapshot if snapshot.current_round == "turn"
        river snapshot if snapshot.current_round == "river"

        @round_counter += 1
    end

    def pre_flop snapshot
        # raise if
        # gap between cards is less then 4 e.g 4-8. This could be a straight
        # all colors are the same. This could be a Flush
        # if the values are the same. This could be a full house, Pair, Two Pair or Three of a kind
        # if sum is greater than 10 * 5 = 50. Could win with high cards.
    
        if ( card_gap(cards) <= 5 || one_suit?(cards) || same_numbers?(cards) ) && @round_counter < 1
            add_action("raise", 20)
        elsif sum(cards) >= 15 
            add_action("call")
        else
            add_action("fold")
        end
    end

    def flop snapshot
        if one_suit?(@all_cards) || same_numbers?(@all_cards)
            add_action("raise", 20)
        elsif sum(@all_cards) >= 50
            add_action("call")
        else
            add_action("fold")
        end
    end

    def turn snapshot
        add_action("call")
    end

    def river snapshot
        add_action("call") 
    end


    # Helpers ---

    def numbers cards
        cards.map { |card| card[0] } 
    end
    
    def colors cards
        cards.map { |card| card[1] } 
    end
    
    def quantity cards
        cards.length
    end
    
    def card_gap cards
        # needs to test with both ais as 1 and 14. 
        # Needs to test combinations if cards are more then 5. 
        numbers(cards).max - numbers(cards).min
    end
    
    def one_suit? cards
        colors(cards).uniq.length == 1
    end
    
    def same_numbers? cards
        numbers(cards).uniq.length == 1
    end
    
    def sum cards
        numbers(cards).map{|number|  number == 1 ? 14 : number }.sum
    end

end