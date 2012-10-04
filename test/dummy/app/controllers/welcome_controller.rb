class WelcomeController < ApplicationController

  include MxitRails::Page

  def index
    input :phone_number, 'Enter your cellphone number'

    validate 'Custom validation message' do |input|
      logger.info "Validation: #{input.inspect}"
      # NB Don't put a return here - it causes much unhappiness
      input != 'custom'
    end
    validate :numeric, 'Please enter numeric digits only'
    validate :min_length, 10, 'Numbers must be at least 10 digits long'
    validate :max_length, 11, 'Numbers cannot be longer than 11 digits'

    @time = Time.now.strftime '%H:%M:%S on %A'

    submit do
      if params[:phone_number] == '1234567890'
        redirect_to '/welcome/easter_egg' and return
      end
      logger.info "This won't execute if an error occurred or if error! or redirect! was called"
      redirect_to '/index/success' and return
    end
  end

  def single
    # We are being lenient with integer values for the hash
    select :select, 'Select an option', {1 => 'Option A', 2 => 'Option B', 3 => 'Option C'}, selected: 2, numbered_list: true

    submit do
      logger.info "Value: #{params[:select]}"
      redirect_to '/index/success' and return
    end
  end

  def multi
    multi_select :select, 'Select all that apply', {1 => 'Option A', 3 => 'Option B', 2 => 'Option C'}, selected: [1, 3], numbered_list: true

    submit do
      logger.info "Value: #{params[:select]}"
      redirect_to '/index/success' and return
    end
  end

  def easter_egg
  end

end
