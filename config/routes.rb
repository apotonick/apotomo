Rails.application.routes.draw do
  match ":controller/render_event_response", :to => "#render_event_response", :as => "apotomo_event", :via => [:get, :post]
end
