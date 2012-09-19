module MxitRails
  module Page
    extend ActiveSupport::Concern

    def mxit_params
      @_mxit_params
    end

    def mxit_form_session
      session[:_mxit_rails_params]
    end


    def set_descriptor name, parent_name=:default
      @descriptors ||= {}
      @descriptors[name] ||= MxitRails::Descriptor.new controller_name, action_name, @descriptors[parent_name]
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

    def redirect! route
      exception = MxitRails::RedirectException.new('', :redirect)
      exception.route = route
      raise exception
    end

    def get_mxit_header_field key
      output = request.headers[key]
      # Only allow cookie-based headers in development
      if Rails.env.development?
        output ||= cookies[key.downcase]
      end
      output
    end

    def get_mxit_info
      @_mxit_params = {}
      @_mxit_params[:m_id] = get_mxit_header_field 'X-Mxit-UserId-R'
      @_mxit_params[:username] = get_mxit_header_field 'x-mxit-login'

      device_info = get_mxit_header_field('X-Mxit-Device-Info')
      unless device_info.blank?
        device_info.split(',')
        @_mxit_params[:distribution_code] = device_info.first
        @_mxit_params[:mobile_number] = device_info[1] if device_info.length == 2
      end
    end


    # Rails controller stuff
    #========================

    def setup
      set_descriptor :default 

      get_mxit_info

      @_mxit = descriptor
      @_mxit_validated = true
      @_mxit_validation_messages = []

      clean_session
    end

    def clean_session
      # Drop all mxit items from session if the page doesn't match the current one
      if (session[:_mxit_rails_page] != "#{controller_name}##{action_name}") || (params[:_mxit_reset])
        session.each do |key, value|
          if key.to_s.match(/_mxit_rails_/)
            session[key] = nil
          end
        end
        session[:_mxit_rails_page] = "#{controller_name}##{action_name}"
      end
    end

    def handle_mxit_exception exception
      if exception.kind_of? MxitRails::RedirectException 
        redirect_to(exception.route) and return
      end
    end

    def input input_name, input_label
      descriptor.input = input_name
      descriptor.input_label = input_label
    end
    def select select_name, select_label, select_options
      descriptor.select = select_name
      descriptor.select_label = select_label
      descriptor.select_options = select_options
    end
    def proceed label
      descriptor.proceed = label
    end

    def run_validation input, method, parameter
      method = method.to_s + '?' #All validations are defined with a trailing question mark
      # Call with/out a parameter, depending on whether one is specified
      parameter ? MxitRails::Validations.send(method, input, parameter) : MxitRails::Validations.send(method, input)
    end

    def validate *arguments, &block
      return unless params.include?(:_mxit_rails_submit)
      return if descriptor.input.nil?

      valid = true
      input = descriptor.input.to_sym

      if block.nil?
        parameter = arguments[1..-2][0] # Will return nil if there isn't an argument

        if !descriptor.form? || (current_step == step_name)
          valid = run_validation params[input], arguments.first, parameter
        end

      else
        valid = yield(params[input])
      end

      if !valid
        @_mxit_validated = false
        @_mxit_validation_messages << arguments.last
      end

    end

    def submit &block
      set_descriptor :default

      if descriptor.form? && next_step?
        yield

      elsif params.include?(:_mxit_rails_submit)
        if @_mxit_validated
          yield
        end
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

      # Process the form if it is the current step
      if current_step == step_name
        set_descriptor step_name
        yield

        if params.include?(:_mxit_rails_submit)
          if @_mxit_validated
            if descriptor.input
              input = descriptor.input.to_sym
              mxit_form_session[input] = params[input]

            elsif descriptor.select
              select = descriptor.select.to_sym
              mxit_form_session[select] = params[select]
            end

            params.delete :_mxit_rails_submit
            @next_step = true
            return
          end
        end

        # Render the form if appropriate
        @_mxit = descriptor
        render "#{controller_name}/#{action_name}/#{current_step}"
      end
    end

    def skip_to step_name
      self.current_step = step_name
      # A redirect might not be absolutely required, but it makes things much simpler
      redirect_to request.path
    end

    def form &block
      descriptor.type = :form
      session[:_mxit_rails_params] ||= {}

      # Ensure previous inputs are in the params hash
      mxit_form_session.each do |key, value|
        params[key.to_sym] = value
      end

      # Proceed to the (first) step if no step is in the session
      @next_step = true if current_step.nil?

      yield

    end
  end
end