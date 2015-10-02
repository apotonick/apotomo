module Apotomo
  autoload :TestCase, 'apotomo/test_case'

  class << self
    def js_framework=(js_framework)
      @js_framework = js_framework
      @js_generator = JavascriptGenerator.new(js_framework)
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
end

require 'apotomo/widget'
require 'apotomo/railtie'
require 'apotomo/widget_shortcuts'
require 'apotomo/rails/controller_methods'
require 'apotomo/javascript_generator'

Apotomo.js_framework = :jquery ### DISCUSS: move to rails.rb
