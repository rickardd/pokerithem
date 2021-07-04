class Helper
    def get_card_image_path card
        suit = ["C", "D", "H", "S"][card.last - 1]
        value = card[0]
        "/cards/#{value}#{suit}.png"
    end
    
end