class RoundTracker
    attr_reader :pre_flop, :flop, :turn, :river

    def initialize
        @pre_flop = true # 0 cards on the table
        @flop = false # 3 cards on the table
        @turn = false # 4 cards on the table
        @river = false # 5 cards on the table
        @end = false # end of rounds
    end

    def set_next
        if !@pre_flop
            @pre_flop = true
        elsif !@flop
            @flop = true
        elsif !@turn
            @turn = true
        elsif !@river
            @river = true
        elsif !@end
            @end = true
        end
    end

    def current
        return "end" if @end
        return "river" if @river
        return "turn" if @turn
        return "flop" if @flop
        return "pre flop"
    end

end
