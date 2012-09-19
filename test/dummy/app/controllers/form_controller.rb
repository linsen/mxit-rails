class FormController < ApplicationController

  include MxitRails::Page

  def index
    form do
      step :start do
        proceed 'Start the form'
      end

      step :name do
        input :name, 'What is your name?'
        validate :not_blank, 'You must enter a name'
        validate 'That is not a cool enough name' do |input|
          input != 'Steve'
        end
      end

      step :surname do
        input :surname, 'What is your surname?'

        @name = params[:name]
      end

      step :age do
        input :age, 'What is your age?'

        validate :numeric, 'Please enter numeric digits only'
        validate :max_length, 2, 'Your age cannot be more than 99'
      end

      step :done do
        proceed 'Submit my information'

        @name = params[:name]
        @surname = params[:surname]
        @age = params[:age]
      end

      submit do
        logger.info "Form Completed!\nname: #{params[:name]};  surname: #{params[:surname]};  age: #{params[:age]}\n******\n\n"
        redirect_to '/index/success' and return
      end
    end
  end

end
