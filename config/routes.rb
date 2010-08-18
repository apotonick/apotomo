ActionController::Routing::Routes.draw do |map|
  map.apotomo_event ':controller/render_event_response', :action => 'render_event_response'
end