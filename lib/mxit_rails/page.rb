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
      @_mxit_params[:mxit_id] = get_mxit_header_field 'X-Mxit-USERID-R'
      @_mxit_params[:mxit_login] = get_mxit_header_field('X-Mxit-Login') || get_mxit_header_field('X-Mxit-ID-R')

      @_mxit_params[:display_name] = get_mxit_header_field 'X-Mxit-Nick'
      @_mxit_params[:nick] = @_mxit_params[:display_name]

      screen_size = get_mxit_header_field 'UA-Pixels'
      unless screen_size.blank?
        screen_size = screen_size.split 'x'
        @_mxit_params[:screen_width] = screen_size[0].to_i
        @_mxit_params[:screen_height] = screen_size[1].to_i
      end
      @_mxit_params[:device_user_agent] = get_mxit_header_field 'X-Device-User-Agent'
      # TODO: Split this into useful subcomponents

      @_mxit_params[:contact] = get_mxit_header_field 'X-Mxit-Contact'
      @_mxit_params[:location] = get_mxit_header_field 'X-Mxit-Location'
      location = @_mxit_params[:location]
      unless location.blank?
        location = location.split ','
        @_mxit_params[:country_code] = location[0] #ISO 3166-1 alpha-2 Country Code
        @_mxit_params[:country_name] = location[1]
        @_mxit_params[:principal_subdivision_code] = location[2]
        @_mxit_params[:principal_subdivision_name] = location[3]
        @_mxit_params[:city_code] = location[4]
        @_mxit_params[:city_name] = location[5]
        @_mxit_params[:network_operator_id] = location[6]
        @_mxit_params[:client_features_bitset] = location[7]
        @_mxit_params[:cell_id] = location[8]
      end
    
      @_mxit_params[:profile] = get_mxit_header_field 'X-Mxit-Profile'
      profile = @_mxit_params[:profile]
      unless profile.blank?
        profile = profile.split ','
        @_mxit_params[:language_code] = profile[0] #ISO_639-1 or ISO_639-2 language code
        @_mxit_params[:registered_country_code] = profile[1] #ISO 3166-1 alpha-2 Country Code
        @_mxit_params[:date_of_birth] = profile[2]
        begin
          # Don't set if it can't parse - ignore exceptions
          @_mxit_params[:date_of_birth] = Date.parse profile[2] #YYYY-MM-dd
        end
        @_mxit_params[:gender] = :unknown
        @_mxit_params[:gender] = :male if profile[3] =~ /male/i
        @_mxit_params[:gender] = :female if profile[3] =~ /female/i
        @_mxit_params[:tariff_plan] = :unknown
        @_mxit_params[:tariff_plan] = :free if profile[4] == '1'
        @_mxit_params[:tariff_plan] = :freestyler if profile[4] == '2'
      end

      user_input = get_mxit_header_field 'X-Mxit-User-Input'
      user_input = URI.unescape(user_input).gsub('+', ' ') unless user_input.blank?
      @_mxit_params[:user_input] = user_input
      # TODO: How closely must it match a link to be ignored?
      # TODO: What happens if there's an input on the page?

      # This is only available on internal services for security reasons
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
      @_mxit_emulator = request.headers['X-Mxit-UserId-R'].nil?

      clean_session

      # Tidy multi-select if needed
      if params.include? :_mxit_rails_multi_select
        input = params[:_mxit_rails_multi_select].to_sym
        params.delete :_mxit_rails_multi_select

        array = mxit_form_session[input] || []
        array.map! {|item| item.to_sym}
        set = Set.new array

        if params.include? :_mxit_rails_multi_select_value
          value = params[:_mxit_rails_multi_select_value].to_sym
          params.delete :_mxit_rails_multi_select_value
          if set.include? value
            set.delete value
          else
            set.add value
          end
        end

        params[input] = set.to_a.map {|item| item.to_s}
        mxit_form_session[input] = set.to_a.map {|item| item.to_sym}
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

    # Override render method so as to inject emoticons, etc
    def render *arguments
      if @_mxit_emulator
        output = render_to_string *arguments
        output = MxitRails::Styles.add_emoticons output
        super :inline => output
      else
        super *arguments
      end
    end

    def input input_name, input_label
      descriptor.input = input_name
      descriptor.input_label = input_label
    end
    def select select_name, select_label, select_options, options = {}
      descriptor.select = select_name
      descriptor.select_label = select_label
      descriptor.select_options = {}
      select_options.each {|k,v| descriptor.select_options[k.to_s.to_sym] = v}
      descriptor.selected = []
      if options.include? :selected
        raise "Invalid :selected options for select - string expected, array received" if options[:selected].is_a?(Array)
        # Convert to string first so that integer values are handled properly
        descriptor.selected = [ options[:selected].to_s.to_sym ]
      end
      descriptor.numbered_list = options[:numbered_list] ? true : false
      descriptor.multi_select = false
    end
    def multi_select select_name, select_label, select_options, options = {}
      descriptor.select = select_name
      descriptor.select_label = select_label
      descriptor.select_options = {}
      select_options.each {|k,v| descriptor.select_options[k.to_s.to_sym] = v}
      if options.include? :selected
        raise "Invalid :selected options for multi_select - array expected, #{options[:selected].class} received" unless options[:selected].is_a?(Array)
        options[:selected].map! {|item| item.to_s.to_sym}
      end
      mxit_form_session[select_name] ||= options[:selected] || []
      descriptor.selected = mxit_form_session[select_name]
      descriptor.numbered_list = options[:numbered_list] ? true : false
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