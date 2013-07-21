Dummy::Application.routes.draw do
  get "barn/widget", :to => "barn#widget"
  get ':controller(/:action(/:id(.:format)))'
end
