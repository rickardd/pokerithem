class ChipSet 
    attr_reader :wallet

    def initialize
        @chips = []
        @wallet = 152
    end

    def add_chip number
        @wallet -= number
        @chips << number
    end

    def get_and_empty 
        existing_chips = @chips
        @chips.clear
        existing_chips
    end
    
    def get 
        @chips.clone
    end

    def sum 
        @chips.sum
    end
end
