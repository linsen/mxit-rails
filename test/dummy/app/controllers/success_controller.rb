class SuccessController < ApplicationController

  include MxitRails::Page

  title 'Success!'
  proceed :index, 'Done'

end