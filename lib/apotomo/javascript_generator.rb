module Apotomo
  class JavascriptGenerator
    def initialize(framework)
      raise "No JS framework specified" if framework.blank?
      extend "apotomo/javascript_generator/#{framework}".camelize.constantize
    end
    
    def <<(javascript)
      "#{javascript}"
    end
    
    # Copied from ActionView::Helpers::JavascriptHelper.
    JS_ESCAPE_MAP = {
      '\\'    => '\\\\',
      '</'    => '<\/',
      "\r\n"  => '\n',
      "\n"    => '\n',
      "\r"    => '\n',
      '"'     => '\\"',
      "'"     => "\\'" }

    # Escape carrier returns and single and double quotes for JavaScript segments.
    def self.escape(javascript)
      return javascript.gsub(/(\\|<\/|\r\n|[\n\r"'])/) { JS_ESCAPE_MAP[$1] } if javascript
      
      ''
    end
    
    def escape(javascript)
      self.class.escape(javascript)
    end
    
    module Prototype
      def prototype;            end
      def element(id);          "$(\"#{id}\")"; end
      def update(id, markup);   element(id) + '.update("'+escape(markup)+'")'; end
      def replace(id, markup);  element(id) + '.replace("'+escape(markup)+'")'; end
    end
    
    module Right
      def right;                end
      def element(id);          "$(\"#{id}\")"; end
      def update(id, markup);   element(id) + '.update("'+escape(markup)+'")'; end
      def replace(id, markup);  element(id) + '.replace("'+escape(markup)+'")'; end
    end
    
    module Jquery
      def jquery;               end
      def element(id);          "$(\"#{id}\")"; end
      def update(id, markup);   element(id) + '.html("'+escape(markup)+'")'; end
      def replace(id, markup);  element(id) + '.replaceWith("'+escape(markup)+'")'; end
    end
  end
end
