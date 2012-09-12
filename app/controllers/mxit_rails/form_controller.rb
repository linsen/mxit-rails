module MxitRails
  class FormController < Controller

    # DSL handling
    #==============
    def init_template
      # self.class.variables.each do |key, value|
      #   instance_variable_set("@#{key}", value)
      # end
      @inputs = inputs
      super
    end

    # getter method for class' steps and inputs
    def steps
      self.class.steps
    end
    def inputs
      if @inputs.nil?
        @inputs = {}
        self.class.inputs.each do |input|
          @inputs[input] = params.include?(input) ? params[input] : nil
        end
      end
      @inputs
    end

    # Class methods - used for defining macros
    #==========================================
    class << self
      attr_reader :steps
      attr_reader :inputs

      # Create a show method that calls the block with the appropriate scope.  Allows it to be declared without a def in the controller
      def step_executor step, method, &block
        # TODO: Don't use a closure?
        define_method method do
          instance_eval &block
        end
      end

      def step name, &block
        name = name.to_sym
        @steps ||= []
        @steps << name
        @scope = name
        instance_eval &block
        @scope = nil
      end

      def input input_name, input_label
        @inputs ||= []
        @inputs << input_name
        super input_name, input_label
      end
    end  

    def current_step
      if @current_step.nil?
        @current_step = steps.first
        if params.include? :step
          @current_step = params[:step].to_sym
        end
      end
      @current_step
    end
    def step_index
      steps.each_with_index do |cur, i|
        if cur == current_step
          return i
        end
      end
      return nil
    end
    def first_step?
      step_index == 0
    end
    def last_step?
      step_index == steps.length - 1
    end
    def next_step
      if last_step?
        return @proceed
      end
      steps[step_index + 1]
    end
    def previous_step
      if first_step?
        return nil
      end
      steps[step_index - 1]
    end

    def index
      if params.include?(:submit)
        init_scope previous_step
        @form_action = mxit_path(@route, current_step)
        # Validate the newest input
        if params.include? @input.to_sym
          validate! params[@input.to_sym], previous_step
        end
        instance_variable_set("@#{@input}", params[@input.to_sym])
        submit(previous_step)

        # Validate the whole form if it is complete
        # validate! params[@input.to_sym], current_step
        # instance_variable_set("@#{@input}", params[@input.to_sym])
        # submit()
      end

      init_scope current_step
      @form_action = mxit_path(@route, next_step)

      show()

      # Update the back link if there is one
      # if @nav_link == :back
      #   @nav_target = previous_step
      # end

      render_template "/#{Rails.application.config.mxit_template_root}/#{route}/#{current_step}"
    end

  end
end