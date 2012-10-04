module MxitRails
  class Descriptor
    attr_accessor :parent_descriptor

    attr_accessor :name
    attr_accessor :action
    attr_accessor :type

    attr_accessor :proceed

    attr_accessor :input
    attr_accessor :input_label

    attr_accessor :select
    attr_accessor :select_label
    attr_accessor :select_options
    attr_accessor :selected
    attr_accessor :multi_select
    attr_accessor :multi_select_next
    attr_accessor :numbered_list

    attr_accessor :has_table

    attr_accessor :validations_failed
    attr_accessor :validated

    def initialize name, action, parent=nil
      @parent_descriptor = parent
      @name = name.to_sym
      @action = action.to_sym
      @validations = []
      @steps = []
    end

    def form?
      type == :form
    end
  end
end
