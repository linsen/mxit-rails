module MxitRails
  module Form

    extend ActiveSupport::Concern
    include MxitRails::Page

    included do
      @descriptors = {
        default: @descriptor
      }
      @current_step = nil
      @steps = []
    end

    def descriptor step=nil
      step ||= session[:_mxit_rails_form_complete] ? :default : current_step
      self.class.descriptor step
    end

    def steps
      self.class.steps
    end
    def current_step
      if session[:_mxit_rails_step].nil?
        session[:_mxit_rails_step] = steps.first
      end
      session[:_mxit_rails_step].to_sym
    end
    def current_step= new_step
      session[:_mxit_rails_step] = new_step
    end
    def current_step_index
      steps.each_with_index do |step, index|
        if step == current_step
          return index
        end
      end
    end
    def first_step?
      current_step_index == 0
    end
    def prev_step
      steps[current_step_index - 1]
    end
    def next_step
      steps[current_step_index + 1]
    end
    def last_step?
      current_step_index == steps.length - 1
    end

    def index
      whitelisted = []
      if session[:_mxit_rails_form] == descriptor.name
        whitelisted = [:_mxit_rails_form, :_mxit_rails_step, :_mxit_rails_form_complete, :_mxit_rails_params]
      end
      clear_session whitelisted

      session[:_mxit_rails_form] = descriptor.name
      session[:_mxit_rails_form_complete] ||= false
      session[:_mxit_rails_params] ||= {}

      # Ensure previous inputs are in the params hash
      session[:_mxit_rails_params].each do |key, value|
        params[key.to_sym] = value
      end

      if params.include?(:_mxit_rails_submit)
        # Validate the current input if present
        unless descriptor.input.nil?
          input = descriptor.input.to_sym
          validate! params[input]
          session[:_mxit_rails_params][input] = params[input]
        end

        submit_block()
        if last_step?
          session[:_mxit_rails_form_complete] = true
          submit_block()
          redirect! descriptor.proceed
        else
          self.current_step = next_step
        end
      end

      render_block()
      @_mxit = descriptor
      render descriptor.view
    end

    # Class methods
    #===============
    module ClassMethods
      attr_reader :steps

      def descriptor step=nil
        current_step = step || @current_step || :default
        @descriptors[current_step]
      end

      def step step_name, &block
        step_name = step_name.to_sym
        @steps << step_name
        @current_step = step_name
        @descriptors[step_name] = MxitRails::Descriptor.new controller_name, descriptor(:default)
        descriptor.step = step_name
        instance_eval &block
        @current_step = nil
      end
    end
  end
end
