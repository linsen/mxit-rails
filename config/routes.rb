Rails.application.routes.draw do

  if Rails.env.development?
    match '/emulator(/*path)', :controller => 'emulator', :action => 'index'
  end

end
