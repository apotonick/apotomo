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
  
  class Engine < Rails::Engine
  end
end

require 'apotomo/javascript_generator'
Apotomo.js_framework = :prototype ### DISCUSS: move to rails.rb

require 'apotomo/widget'
require 'apotomo/stateful_widget'
require 'apotomo/container_widget'
require 'apotomo/widget_shortcuts'
require 'apotomo/rails/controller_methods'

#require 'apotomo/engine' if defined?(Rails)
