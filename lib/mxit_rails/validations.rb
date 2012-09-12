module MxitRails
  class Validations

    def self.not_blank? input
      return !input.blank?
    end

    def self.numeric? input
      return !input.blank? && input.match(/^[0-9]+$/)
    end

    def self.min_length? input, max
      return !input.blank? && (input.length >= max)
    end

    def self.max_length? input, max
      return input.blank? || (input.length <= max)
    end

  end
end