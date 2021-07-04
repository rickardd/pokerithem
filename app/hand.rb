class Hand 
    attr_reader :cards

    def initialize
        @cards = []
    end
    
    def look_at_cards
        return @cards.to_s
    end
    
    def add cards
        @cards << cards
    end

    def get 
        @cards.flatten(1)
    end
end