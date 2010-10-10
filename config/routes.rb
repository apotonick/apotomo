Rails.application.routes.draw do |map|
  match ":controller/render_event_response", :to => "#render_event_response", :as => "apotomo_event"
end
