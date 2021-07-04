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
        (2..14).flat_map { |number| (1..4).map { |color| [number, color] } }.shuffle
    end
end