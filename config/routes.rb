Rails.application.routes.draw do

  match '/emulator', :controller => 'emulator', :action => 'index'

end
