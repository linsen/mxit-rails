module MxitRails
  module Page
    extend ActiveSupport::Concern

    def mxit_params
      @_mxit_params
    end

    def mxit_form_session
      session[:_mxit_rails_params] ||= {}
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
        send :layout, 'mxit'
        send :before_filter, :setup
      end
    end

    def get_mxit_header_field key
      output = request.headers[key]
      # Only allow cookie-based headers in development
      unless Rails.env.production?
        output ||= cookies[key.downcase]
      end
      output
    end

    def get_mxit_info
      @_mxit_params = {}
      @_mxit_params[:mxit_id] = get_mxit_header_field 'X-Mxit-UserId-R'
      @_mxit_params[:mxit_login] = get_mxit_header_field('X-Mxit-Login') || get_mxit_header_field('X-Mxit-ID-R')
      @_mxit_params[:display_name] = get_mxit_header_field 'X-Mxit-Nick'

      @_mxit_params[:distribution_code] = ''
      @_mxit_params[:mobile_number] = ''
      device_info = get_mxit_header_field('X-Mxit-Device-Info')
      unless device_info.blank?
        tmp = device_info.split(',')
        @_mxit_params[:distribution_code] = tmp.first
        @_mxit_params[:mobile_number] = tmp[1] if tmp.length == 2
      end
    end


    # Rails controller stuff
    #========================

    def setup
      set_descriptor :default 

      get_mxit_info

      @_mxit = descriptor
      @_mxit_validated = true
      @_mxit_validation_types = []
      @_mxit_validation_messages = []

      clean_session

      # Tidy multi-select if needed
      if params.include? :_mxit_rails_multi_select
        input = params[:_mxit_rails_multi_select].to_sym
        params.delete :_mxit_rails_multi_select

        array = mxit_form_session[input] || []
        set = Set.new array
        
        if params.include? :_mxit_rails_multi_select_value
          value = params[:_mxit_rails_multi_select_value].to_s
          params.delete :_mxit_rails_multi_select_value
          if set.include? value
            set.delete value
          else
            set.add value
          end
        end

        params[input] = set.to_a
        mxit_form_session[input] = set.to_a
      end
    end

    def clean_session
      # Drop all mxit items from session if the page doesn't match the current one
      page_identifier = request.path
      if (session[:_mxit_rails_page] != page_identifier) || (params[:_mxit_reset])
        session.each do |key, value|
          if key.to_s.match(/_mxit_rails_/)
            session[key] = nil
          end
        end
        session[:_mxit_rails_page] = page_identifier
        params[:first_visit] = true
      else 
        params[:first_visit] = false
      end
    end

    def input input_name, input_label
      descriptor.input = input_name
      descriptor.input_label = input_label
    end
    def select select_name, select_label, select_options, options = {}
      descriptor.select = select_name
      descriptor.select_label = select_label
      descriptor.select_options = select_options
      if options.include? :selected
        raise "Invalid :selected options for select - string expected" unless options[:selected].is_a?(String)
        # Store in an array so that the format is the same as multi_select
        descriptor.selected = [ options[:selected] ]
      end
      descriptor.numbered_list = true if options[:numbered_list]
      descriptor.multi_select = false
    end
    def multi_select select_name, select_label, select_options, options = {}
      descriptor.select = select_name
      descriptor.select_label = select_label
      descriptor.select_options = select_options
      if options.include? :selected
        raise "Invalid :selected options for multi_select - array expected" unless options[:selected].is_a?(Array)
        #TODO: Check the array elements are all strings
      end
      mxit_form_session[select_name] ||= options[:selected] || []
      descriptor.selected = mxit_form_session[select_name]
      descriptor.numbered_list = true if options[:numbered_list]
      descriptor.multi_select = true
      descriptor.multi_select_next = options[:submit_label] || 'Next'
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
      validation_type = arguments.first

      if block.nil?
        parameter = arguments[1..-2][0] # Will return nil if there isn't an argument

        if !descriptor.form? || (current_step == step_name)
          valid = run_validation params[input], arguments.first, parameter
        end

      else
        validation_type = :custom
        valid = yield(params[input])
      end

      if !valid
        @_mxit_validated = false
        @_mxit_validation_types << validation_type
        @_mxit_validation_messages << arguments.last
      end

    end

    def validations_failed &block
      descriptor.validations_failed = block
    end
    def validated &block
      descriptor.validated = block
    end

    def submit &block
      set_descriptor :default

      if descriptor.form? 
        # Submit if the submit block is reached and the next step should be shown
        # Also submit if current_step is :_submit -> result of calling submit!
        if next_step? || (self.current_step == :_submit)
          yield
        end

      # For non-form pages, just check that something was submitted and validations passed
      elsif (params.include?(:_mxit_rails_submit) && @_mxit_validated)
        yield
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
            # Validated hook
            unless descriptor.validated.nil?
              descriptor.validated.call
            end

            # Store input in session
            if descriptor.input
              input = descriptor.input.to_sym
              mxit_form_session[input] = params[input]

            elsif descriptor.select
              select = descriptor.select.to_sym
              mxit_form_session[select] = params[select]
            end

            # Clear submission flag from params and go to next step
            params.delete :_mxit_rails_submit
            @next_step = true
            return
          else
            # Validations_failed hook
            unless descriptor.validations_failed.nil?
              descriptor.validations_failed.call(@_mxit_validation_types, @_mxit_validation_messages)
            end
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

    def submit!
      self.current_step = :_submit
      # A redirect might not be absolutely required, but it makes things much simpler
      redirect_to request.path
    end

    def reset!
      redirect_to "#{request.path}?_mxit_reset=true"
    end

    def form &block
      descriptor.type = :form
      session[:_mxit_rails_params] ||= {}

      # Ensure previous inputs are in the params hash
      mxit_form_session.each do |key, value|
        params[key.to_sym] ||= value
      end

      # Proceed to the (first) step if no step is in the session
      @next_step = true if current_step.nil?

      yield

    end
  end
end