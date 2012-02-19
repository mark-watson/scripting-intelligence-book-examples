ActionController::Routing::Routes.draw do |map|
  map.root :controller => "index"
  map.connect 'show/:id', :controller => 'show', :action => 'index'
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
