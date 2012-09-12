class WelcomeController < ApplicationController

  include MxitRails::Page

  title 'Step 1 of 1'
  back :index

  input :phone_number, 'Enter your cellphone number'

  validate :numeric, 'Please enter a numeric digits only'
  validate :min_length, 10, 'Numbers must be at least 10 digits long'
  validate :max_length, 11, 'Numbers cannot be longer than 11 digits'

  proceed :success

  render do
    @time = Time.now.strftime '%H:%M:%S on %A'
  end

  submit do
    if @phone_number == 'easter egg'
      redirect! :easter_egg

    # Generate native errors for testing
    elsif @phone_number == 'native exception'
      1 / 0
    elsif @phone_number == 'native exception 2'
      nonexistent_method
    elsif @phone_number == 'native exception 3'
      String.nonexistent_method
    end

    logger.info "This won't execute if an error occurred or if error! or redirect! was called"
  end



  handle ZeroDivisionError do |exception|
    logger.error 'Executing code in the ZeroDivisionError handler'
    error! 'A native ZeroDivisionError occurred and was handled in the controller'
  end

  handle NameError, 'A native NameError occurred and was handled in the controller'

  handle NoMethodError, 'A native NoMethodError occurred and was handled in the controller' do
    logger.error 'Executing code in the NoMethodError handler'
  end

end
