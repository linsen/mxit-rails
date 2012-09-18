Rails.application.routes.draw do

  match '/emulator(/*path)', :controller => 'emulator', :action => 'index'

end
