require 'action_view/helpers/javascript_helper'

module Apotomo
  class JavascriptGenerator
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
      def element(selector);            "$(\"#{selector}\")"; end
      def update(selector, markup);     element(selector) + '.update("'+escape(markup)+'");'; end
      def replace(selector, markup);    element(selector) + '.replace("'+escape(markup)+'");'; end

      alias_method :update_id, :update
      alias_method :replace_id, :replace
    end
    
    module Right
      def right;                  end
      def element(selector);            "$(\"#{selector}\")"; end
      def update(selector, markup);     element(selector) + '.update("'+escape(markup)+'");'; end
      def replace(selector, markup);    element(selector) + '.replace("'+escape(markup)+'");'; end

      alias_method :update_id, :update
      alias_method :replace_id, :replace
    end
    
    module Jquery
      def jquery;                 end
      def element(selector)
        selector = selector =~ /^_apo_/ ? selector : "'#{selector}'"
        "$(#{selector})"
      end

      def update(id, markup);     element(id) + '.html("'+escape(markup)+'");'; end
      def replace(id, markup);    element(id) + '.replaceWith("'+escape(markup)+'");'; end

      def update_id(id, markup);  update("##{id}", markup); end
      def replace_id(id, markup); replace("##{id}", markup); end

      def update_text(id, selector, markup)
        element(id) + ".find(#{selector}).text('#{escape(markup)}');"
      end

      def selector_for var, id, selector
        raise ArgumentError, "Must not be an _apo_ selector here: #{selector}" if apo_match?(selector)
        "var _apo_#{var} = " + element(id) + ".find('#{selector}');"
      end

      def find_element id, selector
        element(id) + ".find('#{selector}')"
      end

      def append(id, selector, markup)
        find_element(id, selector) + ".append(#{escaped(markup)});"
      end

      def prepend(id, selector, markup)
        find_element(id, selector) + ".prepend(#{escaped(markup)});"
      end

      def append_to(selector, markup)
        selector = calc_selector selector
        "$(#{escaped(markup)}).appendTo(#{selector});"
      end

      def prepend_to(selector, markup)
        selector = calc_selector selector
        "$(#{escaped(markup)}).prependTo(#{selector});"
      end

      def after selector, markup
        selector = calc_selector selector
        element(selector) + ".after(#{escaped(markup)});"
      end

      def before selector, markup
        selector = calc_selector selector
        element(selector) + ".before(#{escaped(markup)});"
      end

      def replace_all(selector, markup)
        selector = calc_selector selector
        "$(#{escaped(markup)}).replaceAll(#{selector});"
      end    

      def unwrap(selector)
        selector = calc_selector selector
        element(selector) + ".unwrap();"
      end    

      def wrap(selector, markup)
        selector = calc_selector selector
        element(selector) + ".wrap(#{escaped(markup)});"
      end    

      def wrap_inner(selector, markup)
        selector = calc_selector selector
        element(selector) + ".wrapInner(#{escaped(markup)});"
      end    

      def wrap_all(selector, markup)
        selector = calc_selector selector
        element(selector) + ".wrap_all(#{escaped(markup)});"
      end    

      def remove(selector)
        selector = calc_selector selector
        element(selector) + ".remove();"
      end

      def remove_class(selector, *classes)
        classes = classes.flatten.join(' ')
        selector = calc_selector selector
        element(selector) + ".removeClass('#{classes}');"
      end
      alias_method :remove_classes, :remove_class

      def add_class(selector, *classes)
        classes = classes.flatten.join(' ')
        selector = calc_selector selector
        element(selector) + ".addClass('#{classes}');"
      end
      alias_method :add_classes, :add_class

      def toggle_class(selector, *classes)
        classes = classes.flatten.join(' ')
        selector = calc_selector selector
        element(selector) + ".toggleClass('#{classes}');"
      end
      alias_method :toggle_classes, :toggle_class

      def toggle_class_fun(selector, fun)
        selector = calc_selector selector
        element(selector) + ".toggleClass(function() {#{fun}});"
      end

      def get_attr(selector, name)
        selector = calc_selector selector
        element(selector) + ".attr('#{name}');"
      end

      def get_prop(selector, name)
        selector = calc_selector selector
        element(selector) + ".prop('#{name}');"
      end

      def get_val selector
        selector = calc_selector selector
        element(selector) + ".val();"
      end

      def get_html(selector)
        selector = calc_selector selector
        element(selector) + ".html();"
      end

      def empty(selector)
        selector = calc_selector selector
        element(selector) + ".empty();"
      end

      private 

      def escaped markup
        "'#{escape(markup)}'"
      end

      def apo_match? selector
        selector.to_s =~ /^_apo_/
      end

      def calc_selector selector
        selector = apo_selector?(selector) ? "_apo_#{selector}" : "'#{selector}'"
      end

      def apo_selector? selector
        selector.kind_of?(Symbol) && selector.to_s[0..1] == '_'
      end
    end
  end
end
