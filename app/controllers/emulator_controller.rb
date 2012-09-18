class EmulatorController < ApplicationController
  layout false

  def index
    @root_path = Rails.application.config.mxit_root
    @path = params[:path]
  end
end