class Dealer
    def initialize
        @deck = Deck.new
    end
    
    # entity: table or player
    def deal entity, number
        cards = @deck.take number
        entity.hand.add cards
        return cards
    end
end