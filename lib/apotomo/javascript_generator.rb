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
      def prototype;              end
      def element(id);            "$(\"#{id}\")"; end
      def update(id, markup);     element(id) + '.update("'+escape(markup)+'");'; end
      def replace(id, markup);    element(id) + '.replace("'+escape(markup)+'");'; end
      def update_id(id, markup);  update(id, markup); end
      def replace_id(id, markup); replace(id, markup); end
    end

    module Right
      def right;                  end
      def element(id);            "$(\"#{id}\")"; end
      def update(id, markup);     element(id) + '.update("'+escape(markup)+'");'; end
      def replace(id, markup);    element(id) + '.replace("'+escape(markup)+'");'; end
      def update_id(id, markup);  update(id, markup); end
      def replace_id(id, markup); replace(id, markup); end
    end

    module Jquery
      def jquery;                 end
      def element(id);            "$(\"#{id}\")"; end
      def update(id, markup);     element(id) + '.html("'+escape(markup)+'");'; end
      def replace(id, markup);    element(id) + '.replaceWith("'+escape(markup)+'");'; end
      def update_id(id, markup);  update("##{id}", markup); end
      def replace_id(id, markup); replace("##{id}", markup); end

      %w{append prepend before after wrap}.each do |method_with_markup|
        define_method(method_with_markup.to_sym) do |id, markup|
          "#{element(id)}.#{method_with_markup}(\"#{escape(markup)}\");"
        end
      end

      %w{detach empty clone remove}.each do |method_direct_params|
        define_method(method_direct_params.to_sym) do |id, direct_params|
          "#{element(id)}.#{method_direct_params}(#{direct_params});"
        end
      end
    end
  end
end
