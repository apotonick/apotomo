require 'action_view/helpers/javascript_helper'
require 'apotomo/javascript_generator/javascript_helper'

module Apotomo
  class JavascriptGenerator
    include JavascriptHelper

    autoload :Jquery, 'apotomo/javascript_generator/jquery'

    def initialize(framework)
      raise "No JS framework specified" if framework.blank?
      extend "apotomo/javascript_generator/#{framework}".camelize.constantize
    end
    
    def <<(javascript)
      "#{javascript}"
    end
    
    JS_ESCAPER = Object.new.extend(::ActionView::Helpers::JavaScriptHelper)

    # Escape carrier returns and single and double quotes for JavaScript segments.
    def self.escape(javascript)
      JS_ESCAPER.escape_javascript(javascript)
    end
    
    def escape(javascript)
      self.class.escape(javascript)
    end
    
    module Prototype
      def prototype;              end
      def element(id);            "jQuery(\"#{id}\")"; end
      def update(id, markup);     element(id) + '.update("'+escape(markup)+'");'; end
      def replace(id, markup);    element(id) + '.replace("'+escape(markup)+'");'; end
      def update_id(id, markup);  update(id, markup); end
      def replace_id(id, markup); replace(id, markup); end
    end
    
    module Right
      def right;                  end
      def element(id);            "jQuery(\"#{id}\")"; end
      def update(id, markup);     element(id) + '.update("'+escape(markup)+'");'; end
      def replace(id, markup);    element(id) + '.replace("'+escape(markup)+'");'; end
      def update_id(id, markup);  update(id, markup); end
      def replace_id(id, markup); replace(id, markup); end
    end
  end
end
