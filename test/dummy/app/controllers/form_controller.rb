class FormController < ApplicationController

  include MxitRails::Form

  title 'Form'
  back :index

  step :name do
    title 'Step 1 of 3'
    input :name, 'What is your name?'
    validate :not_blank, 'You must enter a name'
  end

  step :surname do
    title 'Step 2 of 3'
    input :surname, 'What is your surname?'
  end

  step :age do
    title 'Step 3 of 3'
    input :age, 'How old are you?'

    validate :numeric, 'Please enter numeric digits only'
    validate :max_length, 2, 'Your age cannot be more than 99'
  end

  step :done do
    proceed :form, 'Submit my information'

    render do
      @name = params[:name]
      @surname = params[:surname]
      @age = params[:age]
    end
  end

  proceed :index

  submit do
    logger.info "Form Completed!\nname: #{params[:name]};  surname: #{params[:surname]};  age: #{params[:age]}\n******\n\n"
  end
  
end
