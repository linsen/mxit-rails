class WelcomeController < ApplicationController

  include MxitRails::Page

  def index
    title 'Step 1 of 1'
    back '/mxit/index'

    input :phone_number, 'Enter your cellphone number'

    validate :numeric, 'Please enter a numeric digits only'
    validate :min_length, 10, 'Numbers must be at least 10 digits long'
    validate :max_length, 11, 'Numbers cannot be longer than 11 digits'

    @time = Time.now.strftime '%H:%M:%S on %A'

    submit do
      if params[:phone_number] == '1234567890'
        redirect! '/mxit/welcome/easter_egg'
      end
      logger.info "This won't execute if an error occurred or if error! or redirect! was called"
      redirect! '/mxit/welcome/success'
    end
  end

  def success
    title 'Success!'
    done '/mxit'
  end

  def easter_egg
    title 'Easter Egg'
    back '/mxit/welcome/index'
  end

end
