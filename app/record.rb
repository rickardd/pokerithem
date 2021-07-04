class Record
    def initialize
       @records = [] 
    end

    def add action, data = nil
        @records << { action: action, data: data}
        puts action
    end

    def get_json
        @records
    end
end