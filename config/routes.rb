Rails.application.routes.draw do

  scope Rails.application.config.mxit_root do
    match ':controller(/:step)', :action => :index

    match '/', :controller => 'index', :action => 'index'
  end

  match '/emulator', :controller => 'emulator', :action => 'index'

end
