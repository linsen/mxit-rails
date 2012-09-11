class MxitController < ApplicationController

  # Custom error class
  #====================
  class MxitException < Exception
    attr_reader :message
    attr_reader :code
    def initialize message, code
      @message = message
      @code = code
    end
  end
  class MxitRedirectException < MxitException
    attr_accessor :route
  end

  rescue_from MxitException, :with => :handle_mxit_exception

  def error! message, code = nil
    raise MxitException.new(message, code)
  end

  def handlers
    self.class.handlers || {}
  end
  def validations
    self.class.validations || []
  end


  # DSL handling
  #==============
  alias route controller_name

  # Create instance variables as necessary for inclusion in templates
  def init_template
    self.class.variables.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
    @route = route
  end

  # Class methods - used for defining macros
  #==========================================
  class << self
    attr_reader :variables
    attr_reader :validations
    attr_reader :handlers

    def handle error_type, message = nil, &block
      # Store the handler message and block
      @handlers ||= {}
      @handlers[error_type] = {message: message, block: block}

      # Tell the controller to rescue that type of exception
      rescue_from error_type, :with => :handle_exception
    end

    # Create class macro that can be called as a "keyword" in template controller definition
    def accessor method, value
      @variables ||= {}
      @variables[method] = value
    end
    # Create a show method that calls the block with the appropriate scope.  Allows it to be declared without a def in the controller
    def executor method, &block
      # TODO: Don't use a closure?
      define_method method do
        instance_eval &block
      end
    end

    def title title_string
      accessor :title, title_string
    end

    def nav_link type, target
      accessor :nav_link, type
      accessor :nav_target, target
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
      executor :show, &block
    end
    def submit &block
      executor :submit, &block
    end

    def input input_name, input_label
      accessor :input, input_name
      accessor :input_label, input_label
    end
    def proceed target, label = nil
      accessor :proceed, target
      accessor :proceed_label, label
    end

    def validate *arguments
      @validations ||= []
      type = arguments[0]
      message = arguments[-1]
      parameter = arguments[1..-2][0] # Will return nil if there isn't an argument
      @validations << {type: type, message: message, parameter: parameter}
    end
  end
  alias :render_template :render

  def redirect! route
    exception = MxitRedirectException.new('', :redirect)
    exception.route = route
    raise exception
  end

  alias :old_redirect_to :redirect_to
  def redirect_to route
    old_redirect_to "/#{route}"
  end

  # Actual validation methods
  #===========================
  def validate_numeric input
    return input.match(/^[0-9]+$/)
  end
  def validate_min_length input, max
    return input.length >= max
  end
  def validate_max_length input, max
    return input.length <= max
  end

  def validate! input
    validations.each do |validation|
      method = "validate_#{validation[:type].to_s}"
      parameter = validation[:parameter]
      # Call with/out a parameter, depending on whether one is specified
      valid = parameter ? send(method, input, parameter) : send(method, input)
      if !valid
        error! validation[:message]
      end
    end
  end


  # Rails controller stuff
  #========================
  layout 'mxit'

  before_filter :init_template

  def index
    if params.include?(:submit) and respond_to?(:submit)
      validate! params[@input.to_sym]
      instance_variable_set("@#{@input}", params[@input.to_sym])
      submit()
      redirect_to(@proceed) and return
    end

    show() if respond_to? :show
    render_template :action => route
  end

  def render_error message
    @error_message = message
    render_template :action => :error
  end

  def handle_mxit_exception exception
    if exception.kind_of? MxitRedirectException 
      redirect_to(exception.route) and return

    elsif exception.kind_of? MxitException
      render_error exception.message
    end
  end

  # This will only be called for explicitly whitelisted exception types
  def handle_exception exception
    handler = handlers[exception.class]
    # Execute the block if there is one.  Use its return value as the error message if a default wasn't given
    unless handler[:block].nil?
      begin
        instance_exec exception, &handler[:block]

      # Only catch MxitExceptions from the error block - everything else is an actual error
      rescue MxitException => e
        handle_mxit_exception e and return
      end
    end
    # Use the error message in the handler if there is one
    render_error handler[:message] || "Internal server error"
  end

end
