module Apotomo
  class JavascriptGenerator
    def initialize(framework)
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
    def escape(javascript)
      if javascript
        javascript.gsub(/(\\|<\/|\r\n|[\n\r"'])/) { JS_ESCAPE_MAP[$1] }
      else
        ''
      end
    end
    
    module Prototype
      def element(id);          "$(\"#{id}\")"; end
      def xhr(url);             "new Ajax.Request(\"#{url}\")"; end
      def update(id, markup);   element(id) + '.update("'+escape(markup)+'")'; end
      def replace(id, markup);  element(id) + '.replace("'+escape(markup)+'")'; end
    end
  end
end