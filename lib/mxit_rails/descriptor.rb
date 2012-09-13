module MxitRails
  class Descriptor
    def self.descr_accessor variable
      # Custom accessor macro that will look in a parent descriptor if a value isn't found (i.e. is nil)
      attr_writer variable
      define_method "#{variable}" do
        value = instance_variable_get("@#{variable}")
        if value.nil? && !parent_descriptor.nil?
          value = parent_descriptor.send("#{variable}")
        end
        value
      end
    end

    attr_accessor :parent_descriptor

    attr_accessor :name
    attr_accessor :step

    descr_accessor :title
    descr_accessor :proceed
    descr_accessor :proceed_label

    descr_accessor :nav_link
    descr_accessor :nav_target

    attr_accessor :input
    attr_accessor :input_label

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

    def initialize name, parent=nil
      @parent_descriptor = parent
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

    def view
      view = MxitRails::Router.url name
      unless step.nil?
        view += "/#{step}"
      end
      view
    end

  end
end
