module MxitRails
  module Page
    extend ActiveSupport::Concern

    included do
      if self.ancestors.include? ApplicationController
        @descriptor = MxitRails::Descriptor.new controller_name

        send :rescue_from, MxitRails::Exception, :with => :handle_mxit_exception
        send :layout, 'mxit'
      end
    end

    def descriptor
      self.class.descriptor
    end

    def error! message, code = nil
      raise MxitRails::Exception.new(message, code)
    end

    def redirect! route
      exception = MxitRails::RedirectException.new('', :redirect)
      exception.route = route
      raise exception
    end

    def redirect_to route
      super MxitRails::Router.url(route)
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

    def render_block current_descriptor=nil
      current_descriptor ||= descriptor
      instance_eval &current_descriptor.render if descriptor.render?
    end
    def submit_block current_descriptor=nil
      current_descriptor ||= descriptor
      instance_eval &current_descriptor.submit if descriptor.submit?
    end

    def clear_session whitelisted=[]
      whitelisted.map! {|item| item.to_sym}
      session.each do |key, value|
        if (key.to_s.match /_mxit_rails_/) && !whitelisted.include?(key.to_sym)
          session[key] = nil
        end
      end
    end



    # Rails controller stuff
    #========================

    def index
      clear_session

      if params.include?(:_mxit_rails_submit)
        unless descriptor.input.nil?
          input = descriptor.input.to_sym
          validate! params[input]
        end
        submit_block()
        redirect! descriptor.proceed
      end

      render_block()
      @_mxit = descriptor
      render descriptor.view
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

    # This will only be called for explicitly whitelisted exception types
    def handle_exception exception
      handler = descriptor.error_handlers[exception.class]
      # Execute the block if there is one.  Use its return value as the error message if a default wasn't given
      unless handler[:block].nil?
        begin
          instance_exec exception, &handler[:block]

        # Only catch MxitRails::Exceptions from the error block - everything else is an actual error
        rescue MxitRails::Exception => e
          handle_mxit_exception e and return
        end
      end
      # Use the error message in the handler if there is one
      render_error handler[:message] || "Internal server error"
    end



    # Class methods - These are the macros available when writing a controller
    #==========================================================================
    module ClassMethods
      attr_reader :descriptor

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

      def render &block
        descriptor.render = block
      end
      def submit &block
        descriptor.submit = block
      end

      def input input_name, input_label
        descriptor.input = input_name
        descriptor.input_label = input_label
      end
      def proceed target, label=nil
        descriptor.proceed = target
        descriptor.proceed_label = label
      end

      def validate *arguments
        type = arguments[0]
        message = arguments[-1]
        parameter = arguments[1..-2][0] # Will return nil if there isn't an argument
        descriptor.add_validation type, message, parameter
      end

      def handle error_type, message = nil, &block
        # Store the handler message and block
        descriptor.add_error_handler error_type, message, block

        # Tell the controller to rescue that type of exception
        rescue_from error_type, :with => :handle_exception
      end

    end
  end
end