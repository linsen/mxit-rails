module MxitRails
  module Page
    extend ActiveSupport::Concern

    attr_accessor :mxit_params
    attr_reader :descriptor

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

    def submit &block
      if params.include?(:_mxit_rails_submit)
        unless descriptor.input.nil?
          input = descriptor.input.to_sym
          validate! params[input]
        end
        instance_eval &block unless block.nil?
      end
    end

    def clear_session whitelisted=[]
      whitelisted.map! {|item| item.to_sym}
      session.each do |key, value|
        if (key.to_s.match /_mxit_rails_/) && !whitelisted.include?(key.to_sym)
          session[key] = nil
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
      @descriptor = MxitRails::Descriptor.new controller_name

      get_mxit_info
      clear_session

      @_mxit = descriptor
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
  end
end