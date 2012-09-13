class IndexController < ApplicationController

  include MxitRails::Page

  def index
    title 'Templater'
    done :index
  end

end
