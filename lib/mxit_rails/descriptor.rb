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
    attr_accessor :type

    descr_accessor :proceed

    attr_accessor :input
    attr_accessor :input_label

    attr_accessor :validations

    def initialize name, parent=nil
      @parent_descriptor = parent
      self.name = name.to_sym
      @validations = []
      @steps = []
    end

    def add_validation type, message, parameter
      @validations << {type: type, message: message, parameter: parameter}
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

    def form?
      type == :form
    end
  end
end
