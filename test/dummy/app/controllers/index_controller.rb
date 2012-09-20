class IndexController < ApplicationController

  include MxitRails::Page

  def index
    @mxit_params = mxit_params
  end

  def success
  end


end
