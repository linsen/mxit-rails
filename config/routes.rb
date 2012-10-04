Rails.application.routes.draw do

  unless Rails.env.production?
    match '/emulator(/*path)', :controller => 'emulator', :action => 'index'
  end

end
