module CheckWriter

  # Provides formatting methods for Check attributes
  module AttributeFormatting

    # Returns an integer representing the number of cents of the amount
    #
    # amount = 3.23 => 23
    def cents
      ((amount.to_f - dollars) * 100).round
    end

    # Returns an integer representing the number of dollars of the amount
    #
    # amount = 3.23 => 3
    def dollars
      amount.to_i
    end

    # Formats the amount as currency
    #
    # amount = 1000 => $1,000.00
    def formatted_amount
      separated_dollars = dollars.to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
      cents_string = (cents < 10) ? "0#{cents}" : cents
      "$#{separated_dollars}.#{cents_string}"
    end

    # Converts numeric amount of the check into words.
    #
    # amount = 1.12 => One Dollar and Twelve Cents
    def amount_in_words
      # Wrap cents in string before calling numwords to avoid 
      # SafeBuffer cannot modify string in place error
      cents = "#{self.cents}".en.numwords

      "#{dollars.en.numwords} Dollars and #{cents} Cents".titleize
    end

    # Formats date
    def formatted_date
      date.strftime('%m/%d/%Y')
    end

  end

end
