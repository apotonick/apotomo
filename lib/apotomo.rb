#  Copyright (c) 2007-2010 Nick Sutterer <apotonick@gmail.com>
#  
#  The MIT License
#  
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#  
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#  
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

require "rails/railtie"
 
module Apotomo
  class << self
    def js_framework=(js_framework)
      @js_framework = js_framework
      @js_generator = ::Apotomo::JavascriptGenerator.new(js_framework)
    end
    
    attr_reader :js_generator, :js_framework
    
    # Apotomo setup/configuration helper for initializer.
    #
    # == Usage/Examples:
    #
    #   Apotomo.setup do |config|
    #     config.js_framework = :jquery
    #   end
    def setup
      yield self
    end
  end
  
  # Piotr Sarnacki: Railtie :P
  class Railtie < Rails::Railtie
    rake_tasks do
      load "apotomo/apotomo.rake"
    end
    
    # As we are a Railtie only, the routes won't be loaded automatically. Beside that, we want our 
    # route to be the very first (otherwise #resources might supersede it).
    initializer :prepend_apotomo_routes, :after => :add_routing_paths do |app|
      app.routes_reloader.paths.unshift(File.dirname(__FILE__) + "/../config/routes.rb")
    end
  end 
end


require 'apotomo/widget'
require 'apotomo/container_widget'
require 'apotomo/widget_shortcuts'
require 'apotomo/rails/controller_methods'


require 'apotomo/javascript_generator'
Apotomo.js_framework = :jquery ### DISCUSS: move to rails.rb

### FIXME: only load in test env.
require 'apotomo/test_case' #if defined?("Rails") and Rails.env == "test"
