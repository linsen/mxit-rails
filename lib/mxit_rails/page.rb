module MxitRails
  module Page
    extend ActiveSupport::Concern

    attr_accessor :mxit_params

    def set_descriptor name, parent_name=:default
      @descriptors ||= {}
      @descriptors[name] ||= MxitRails::Descriptor.new controller_name, @descriptors[parent_name]
      @descriptor_name = name
    end
    def descriptor
      @descriptors[@descriptor_name]
    end

    included do
      if self.ancestors.include? ApplicationController
        send :rescue_from, MxitRails::Exception, :with => :handle_mxit_exception
        send :layout, 'mxit'
        send :before_filter, :setup
      end
    end

    def error! message, code = nil
      raise MxitRails::Exception.new(message, code)
    end

    def redirect! route
      exception = MxitRails::RedirectException.new('', :redirect)
      exception.route = route
      raise exception
    end

    def validate! input
      descriptor.validations.each do |validation|
        method = validation[:type].to_s + '?' #All validations are defined with a trailing question mark
        parameter = validation[:parameter]
        # Call with/out a parameter, depending on whether one is specified
        valid = parameter ? MxitRails::Validations.send(method, input, parameter) : MxitRails::Validations.send(method, input)
        if !valid
          error! validation[:message]
        end
      end
    end

    def get_mxit_header_field key
      request.headers[key] || cookies[key.downcase]
    end

    def get_mxit_info
      mxit_params = {}
      mxit_params[:m_id] = get_mxit_header_field 'X-Mxit-UserId-R'
      mxit_params[:username] = get_mxit_header_field 'x-mxit-login'

      device_info = get_mxit_header_field('X-Mxit-Device-Info')
      unless device_info.blank?
        device_info.split(',')
        mxit_params[:distribution_code] = device_info.first
        mxit_params[:mobile_number] = device_info[1] if device_info.length == 2
      end
    end


    # Rails controller stuff
    #========================

    def setup
      set_descriptor :default 

      get_mxit_info

      @_mxit = descriptor

      clean_session
    end

    def clean_session
      # Drop all mxit items from session if the page doesn't match the current one
      if session[:_mxit_rails_page] != "#{controller_name}##{action_name}"
        session.each do |key, value|
          if key.to_s.match(/_mxit_rails_/)
            session[key] = nil
          end
        end
        session[:_mxit_rails_page] = "#{controller_name}##{action_name}"
      end
    end

    def render_error message
      @_mxit_error_message = message
      @_mxit = descriptor
      render "mxit_rails/error"
    end

    def handle_mxit_exception exception
      if exception.kind_of? MxitRails::RedirectException 
        redirect_to(exception.route) and return

      elsif exception.kind_of? MxitRails::Exception
        render_error exception.message
      end
    end

    def title title_string
      descriptor.title = title_string
    end

    def nav_link type, target
      descriptor.nav_link = type
      descriptor.nav_target = target
    end
    def back target
      nav_link :back, target
    end
    def cancel target
      nav_link :cancel, target
    end
    def done target
      nav_link :done, target
    end

    def input input_name, input_label
      descriptor.input = input_name
      descriptor.input_label = input_label
    end
    def proceed label
      descriptor.proceed = label
    end

    def validate *arguments
      type = arguments[0]
      message = arguments[-1]
      parameter = arguments[1..-2][0] # Will return nil if there isn't an argument
      descriptor.add_validation type, message, parameter
    end

    def submit &block
      set_descriptor :default

      if descriptor.form? && next_step?
        instance_eval &block

      elsif params.include?(:_mxit_rails_submit)
        unless descriptor.input.nil?
          input = descriptor.input.to_sym
          validate! params[input]
        end
        instance_eval &block
      end
    end


    def current_step
      return nil if session[:_mxit_rails_step].nil?
      session[:_mxit_rails_step].to_sym
    end
    def current_step= new_step
      session[:_mxit_rails_step] = new_step.to_sym
    end
    def next_step?
      @next_step
    end

    def step step_name, &block
      # Is the current step blank
      if next_step?
        self.current_step = step_name
        @next_step = false
      end

      set_descriptor step_name
      instance_eval &block

      # Process the form if it is the current step
      if current_step == step_name
        if params.include?(:_mxit_rails_submit)
          # Validate the current input if present
          unless descriptor.input.nil?
            input = descriptor.input.to_sym
            validate! params[input]
            session[:_mxit_rails_params][input] = params[input]
          end

          params.delete :_mxit_rails_submit
          @next_step = true
          return
        end

        # Render the form if appropriate
        @_mxit = descriptor
        render "#{controller_name}/#{action_name}/#{current_step}"
      end
    end

    def form &block
      descriptor.type = :form
      session[:_mxit_rails_params] ||= {}

      # Ensure previous inputs are in the params hash
      session[:_mxit_rails_params].each do |key, value|
        params[key.to_sym] = value
      end

      # Proceed to the (first) step if no step is in the session
      @next_step = true if session[:_mxit_rails_step].nil?

      instance_eval &block
    end
  end
end