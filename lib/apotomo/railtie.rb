require "rails/railtie"

module Apotomo
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "apotomo/apotomo.rake"
    end

    # In Rails 5.1, a dynamic :controller segment in a route is deprecated.
    # The routes for each controller have to be added in routes.rb.
    if ::ActiveRecord.gem_version < ::Gem::Version.new("5.1.0.beta1")
      # As we are a Railtie only, the routes won't be loaded automatically. Beside that, we want our
      # route to be the very first (otherwise #resources might supersede it).
      initializer 'apotomo.prepend_routes', :after => :add_routing_paths do |app|
        app.routes_reloader.paths.unshift(File.dirname(__FILE__) + "/../../config/routes.rb")
      end
    end

    # Include a lazy loader via has_widgets.
    initializer 'apotomo.add_has_widgets' do |app|
      ActionController::Base.extend Apotomo::Rails::ControllerMethodsLoader
    end
  end
end
