module MxitRails
  class Validations

    def self.not_blank? input
      return !input.blank?
    end

    def self.numeric? input
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


  end
end