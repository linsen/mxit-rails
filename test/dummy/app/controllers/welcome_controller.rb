class WelcomeController < ApplicationController

  include MxitRails::Page

  def index
    input :phone_number, 'Enter your cellphone number'

    validate 'Custom validation message' do |input|
      logger.info "Validation: #{input.inspect}"
      # NB Don't put a return here - it causes much unhappiness
      input != 'custom'
    end
    validate :numeric, 'Please enter a numeric digits only'
    validate :min_length, 10, 'Numbers must be at least 10 digits long'
    validate :max_length, 11, 'Numbers cannot be longer than 11 digits'

    @time = Time.now.strftime '%H:%M:%S on %A'

    submit do
      if params[:phone_number] == '1234567890'
        redirect! :easter_egg
      end
      logger.info "This won't execute if an error occurred or if error! or redirect! was called"
      redirect! '/mxit/index/success'
    end
  end

  def easter_egg
  end

end
