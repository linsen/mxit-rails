module MxitRails
  class Descriptor
    attr_accessor :name
    attr_accessor :title
    attr_accessor :proceed
    attr_accessor :proceed_label

    attr_accessor :nav_link
    attr_accessor :nav_target

    attr_accessor :input
    attr_accessor :input_label

    attr_accessor :validations
    attr_accessor :error_handlers

    attr_accessor :render
    def render?
      return !render.nil?
    end
    attr_accessor :submit
    def submit?
      return !submit.nil?
    end

    attr_accessor :validations
    attr_accessor :error_handlers

    def initialize name
      self.name = name.to_sym
      @validations = []
      @error_handlers = {}
    end

    def add_validation type, message, parameter
      @validations << {type: type, message: message, parameter: parameter}
    end

    def add_error_handler type, message, block
      @error_handlers[type] = {message: message, block: block}
    end

    def url
      MxitRails::Router.url name
    end

  end
end
