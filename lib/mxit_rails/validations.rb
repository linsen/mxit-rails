module MxitRails
  class Validations

    def self.not_blank? input
      return !input.blank?
    end

    def self.numeric? input
      input.gsub!(/\s*/, '') if !input.blank?
      return !input.blank? && input.match(/^[0-9]+$/)
    end

    def self.length? input, len
      return !input.blank? && (input.length == len)
    end

    def self.min_length? input, max
      return !input.blank? && (input.length >= max)
    end

    def self.max_length? input, max
      return input.blank? || (input.length <= max)
    end

    def self.min_value? input, min
      return input.to_f >= min
    end

    def self.max_value? input, max
      return input.to_f <= max
    end

    def self.cellphone_number? input
      return false unless numeric?(input)

      # Normalise to local 0xx format
      input.sub! /^00/, '0'
      input.sub! /^\+/, ''
      input.sub! /^27/, '0'

      # Check length is 10, and first digits are 07 or 08
      return false unless length?(input, 10)
      return false unless ((input =~ /^07/) || (input =~ /^08/))

      return true
    end

    def self.sa_id_number? input
      return false unless numeric?(input)

      #1. numeric and 13 digits
      return false unless length?(input, 13)

      #2. first 6 numbers is a valid date
      dateString = "#{input[0..1]}-#{input[2..3]}-#{input[4..5]}"
      begin
        date = Date.parse dateString
      rescue ArgumentError
        return false
      end

      #3. luhn formula
      temp_total = 0
      checksum = 0
      multiplier = 1
      (0..12).each do |i|
        temp_total = input[i].to_i * multiplier
        if temp_total > 9
          temp_total = temp_total.to_s[0].to_i + temp_total.to_s[1].to_i
        end
        checksum += temp_total
        multiplier = multiplier.even? ? 1 : 2
      end
      return checksum % 10 == 0
    end


  end
end