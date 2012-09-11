Rails.application.routes.draw do

  match ':controller', :action => :index

  root :to => 'index#index'

end
