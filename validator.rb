class Validator
    
    ROYAL_FLUSH_VALUE = 10
    STRAIGHT_FLUSH_VALUE = 9
    FOUR_OF_A_KING_VALUE = 8
    FULL_HOUSE_VALUE = 7
    FLUSH_VALUE = 6
    STRIGHT_VALUE = 5
    THREE_OF_A_KIND_VALUE = 4 
    TWO_PAIR_VALUE = 3
    ONE_PAIR_VALUE = 2
    HIGHT_CARDS_VALUE = 1

    ROYAL_FLUSH_NAME = "royal flush"
    STRAIGHT_FLUSH_NAME = "straight flush"
    FOUR_OF_A_KING_NAME = "four of a king"
    FULL_HOUSE_NAME = "full house"
    FLUSH_NAME = "flush"
    STRIGHT_NAME = "straight"
    THREE_OF_A_KIND_NAME = "three of a kind"
    TWO_PAIR_NAME = "two pair"
    ONE_PAIR_NAME = "one pair"
    HIGHT_CARDS_NAME = "hight cards"
    
    class CardSet
        def initialize cards
            @cards = cards
        end 
        
        def numbers
            @cards.map { |card| card[0] } 
        end
        
        def colors
            @cards.map { |card| card[1] } 
        end
        
        def raw
            @cards
        end
    end
    
    def validate cards
        @cards = CardSet.new cards
        return { name: ROYAL_FLUSH_NAME, value: royal_flush, sum: sum }.to_h if royal_flush?
        return { name: STRAIGHT_FLUSH_NAME, value: straight_flush, sum: sum }.to_h if straight_flush?
        return { name: FOUR_OF_A_KING_NAME, value: four_of_a_king, sum: sum }.to_h if four_of_a_king?
        return { name: FULL_HOUSE_NAME, value: full_house, sum: sum }.to_h if full_house?
        return { name: FLUSH_NAME, value: flush, sum: sum }.to_h if flush?
        return { name: STRIGHT_NAME, value: straight, sum: sum }.to_h if straight?
        return { name: THREE_OF_A_KIND_NAME, value: three_of_a_kind, sum: sum }.to_h if three_of_a_kind?
        return { name: TWO_PAIR_NAME, value: two_pair, sum: sum }.to_h if two_pair?
        return { name: ONE_PAIR_NAME, value: one_pair, sum: sum }.to_h if one_pair?
        return { name: HIGHT_CARDS_NAME, value: hight_cards, sum: sum }.to_h if hight_cards?
    end
    
    private
    
    #helper method
    def is_same_color?
        @cards.colors.uniq.length == 1
    end
    
    def is_straight?
        numbers = @cards.numbers.sort
        numbers == (numbers.first..numbers.first + 4).to_a
    end
    
    # main methods
    def royal_flush 
        ROYAL_FLUSH_VALUE if [10, 11, 12, 13, 14] == @cards.numbers.sort && is_same_color?
    end
    
    def straight_flush
        STRAIGHT_FLUSH_VALUE if is_straight? && is_same_color?
    end
    
    def four_of_a_king
        FOUR_OF_A_KING_VALUE if @cards.numbers.uniq.map { |number| @cards.numbers.count(number) }.sort == [1,4]
    end
    
    def full_house
        FULL_HOUSE_VALUE if @cards.numbers.uniq.map { |number| @cards.numbers.count(number) }.sort == [2,3]
    end
    
    def flush
        FLUSH_VALUE if @cards.colors.uniq.length == 1
    end
    
    def straight
        STRIGHT_VALUE if is_straight?
    end
    
    def three_of_a_kind
        THREE_OF_A_KIND_VALUE if @cards.numbers.uniq.map { |number| @cards.numbers.count(number) }.sort.last == 3
    end
    
    def two_pair
        TWO_PAIR_VALUE if @cards.numbers.uniq.map { |number| @cards.numbers.count(number) }.sort == [1,2,2]
    end
    
    def one_pair
        ONE_PAIR_VALUE if  @cards.numbers.uniq.map { |number| @cards.numbers.count(number) }.select { |number| number == 2 }.length == 1
    end
    
    def hight_cards
        HIGHT_CARDS_VALUE if !(
            royal_flush? ||
            straight_flush? ||
            four_of_a_king? ||
            full_house? ||
            flush? ||
            straight? ||
            three_of_a_kind? ||
            two_pair? ||
            one_pair?
        )
    end

    def sum
        @cards.numbers.sum
    end
    
    
    def royal_flush?
        ROYAL_FLUSH_VALUE == royal_flush 
    end
    
    def straight_flush?
        STRAIGHT_FLUSH_VALUE == straight_flush
    end
    
    def four_of_a_king?
        FOUR_OF_A_KING_VALUE == four_of_a_king
    end
    
    def full_house?
        FULL_HOUSE_VALUE == full_house
    end
    
    def flush?
        FLUSH_VALUE == flush
    end
    
    def straight?
        STRIGHT_VALUE == straight
    end
    
    def three_of_a_kind?
        THREE_OF_A_KIND_VALUE == three_of_a_kind
    end
    
    def two_pair?
        TWO_PAIR_VALUE == two_pair
    end
    
    def one_pair?
        ONE_PAIR_VALUE == one_pair
    end
    
    def hight_cards?
        HIGHT_CARDS_VALUE == hight_cards
    end

end

# validator = Validator.new

# # Royal flush
# puts validator.validate([[10, 1], [11, 1], [12, 1], [13, 1], [14, 1]])
# puts validator.validate([[13, 1], [11, 1], [12, 1], [10, 1], [14, 1]])

# # straight_flush
# puts validator.validate([[3, 1], [4, 1], [5, 1], [6, 1], [7, 1]])
# puts validator.validate([[7, 2], [4, 2], [5, 2], [6, 2], [3, 2]])

# # four_of_a_king
# puts validator.validate([[3, 1], [3, 2], [3, 3], [3, 4], [7, 1]])
# puts validator.validate([[3, 1], [3, 2], [7, 3], [3, 4], [3, 1]])

# # full_house
# puts validator.validate([[1, 1], [1, 2], [1, 3], [2, 4], [2, 1]])
# puts validator.validate([[1, 1], [2, 4], [1, 2], [2, 3], [1, 4]])

# # flush
# puts validator.validate([[1, 1], [2, 1], [1, 1], [2, 1], [1, 1]])

# # straight
# puts validator.validate([[1, 1], [2, 1], [3, 1], [4, 1], [5, 1]])

# # three_of_a_kind
# puts validator.validate([[1, 1], [1, 1], [1, 1], [3, 1], [4, 1]])

# # two_pair
# puts validator.validate([[1, 1], [1, 1], [4, 1], [3, 1], [4, 1]])

# # one_pair
# puts validator.validate([[2, 1], [10, 1], [3, 1], [5, 1], [2, 1]])

# # heigh_cards
# puts validator.validate([[2, 2], [3, 1], [4, 1], [10, 1], [11, 1]])



