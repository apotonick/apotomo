Rails.application.routes.draw do
  match ":controller/render_event_response", :action => "render_event_response", :as => "apotomo_event", :via =>  [:get, :post, :put, :patch, :delete]
end
