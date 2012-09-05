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

      def update_text(id, selector, markup)
        element(id) + ".find(#{selector}).text('#{escape(markup)}');"
      end

      def append(id, selector, markup)
        element(id) + ".find(#{selector}).append('#{escape(markup)}');"
      end

      def prepend(id, selector, markup)
        element(id) + ".find(#{selector}).prepend('#{escape(markup)}');"
      end

      def append_to(selector, markup)
        "$(#{escape(markup)}').appendTo('#{selector}');"
      end

      def prepend_to(selector, markup)
        "$(#{escape(markup)}').prependTo('#{selector}');"
      end

      def after selector, markup
        "$('#{selector}').after('#{escape(markup)}');"
      end

      def before selector, markup
        "$('#{selector}').before('#{escape(markup)}');"
      end

      def replace_all(selector, markup)
        "$(#{escape(markup)}').replaceAll('#{selector}');"
      end    

      def unwrap (selector)
        "$('#{selector}').unwrap();"
      end    

      def wrap (selector, markup)
        "$('#{selector}').wrap('#{escape(markup)}');"
      end    

      def wrap_innet (selector, markup)
        "$('#{selector}').wrapInner('#{escape(markup)}');"
      end    

      def wrap_all (selector, markup)
        "$('#{selector}').wrap_all('#{escape(markup)}');"
      end    

      def remove(selector)
        "$('#{selector}').remove();"
      end

      def remove_class(selector, *classes)
        classes = classes.flatten.join(' ')
        "$('#{selector}').removeClass('#{classes}');"
      end
      alias_method :remove_classes, :remove_class

      def add_class(selector, *classes)
        classes = classes.flatten.join(' ')
        "$('#{selector}').addClass('#{classes}');"
      end
      alias_method :add_classes, :add_class

      def toggle_class(selector, *classes)
        classes = classes.flatten.join(' ')
        "$('#{selector}').toggleClass('#{classes}');"
      end
      alias_method :toggle_classes, :toggle_class

      def toggle_class_fun(selector, fun)        
        "$('#{selector}').toggleClass(function() {#{fun}});"
      end

      def get_attr(selector, name)
        "$('#{selector}').attr('#{name}');"
      end

      def get_prop(selector, name)
        "$('#{selector}').prop('#{name}');"
      end

      def get_val selector
        "$('#{selector}').val();"
      end

      def get_html(selector)
        "$('#{selector}').html();"
      end

      def empty(selector)
        "$('#{selector}').empty();"
      end
    end
  end
end
