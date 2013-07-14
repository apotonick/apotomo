Rails.application.routes.draw do
  if Rails::VERSION::MAJOR >= 4
    get ":controller/render_event_response", :to => "#render_event_response", :as => "apotomo_event"
  else
    match ":controller/render_event_response", :to => "#render_event_response", :as => "apotomo_event"
  end
end
