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
        "var _apo_#{var} = " + element("##{id}") + ".find('#{selector}');"
      end

      def find_element id, selector        
        if id == nil || apo_selector?(selector)
          return element(calc_selector selector)
        end
        element("##{id}") + ".find('#{selector}')"
      end

      [:replace_all, :prepend_to, :append_to].each do |name|
        define_method name do |selector, markup|
          _jq_inverse_action(selector, markup, name.to_sym)
        end
      end

      [:append, :prepend, :after, :before, :wrap, :wrap_inner, :wrap_all].each do |name|
        define_method name do |args|      
          _jquery_action *args, name
        end
      end

      def unwrap *args
        jquery_action *args, 'unwrap()'
      end    

      def remove *args
        _jquery_action *args, 'remove()'
      end

      def remove_class(id, selector, *classes)
        classes = classes.flatten.join(' ')
        find_element(id, selector) + _js_action("removeClass('#{classes}')")
      end
      alias_method :remove_classes, :remove_class

      def add_class(id, selector, *classes)
        classes = classes.flatten.join(' ')
        find_element(id, selector) + _js_action("addClass('#{classes}')"
      end
      alias_method :add_classes, :add_class

      def toggle_class(id, selector, *classes)
        classes = classes.flatten.join(' ')
        find_element(id, selector) + _js_action("toggleClass('#{classes}')")
      end
      alias_method :toggle_classes, :toggle_class

      def toggle_class_fun(id, selector, fun)        
        find_element(id, selector) + _js_action("toggleClass(function() {#{fun}})")
      end

      def get_attr(id. selector, name)
        find_element(id, selector) + _js_action("attr('#{name}')")
      end

      def get_prop(selector, name)        
        find_element(id, selector) + _js_action("prop('#{name}')")
      end

      def get_val selector        
        find_element(id, selector) + _js_action("val()")
      end

      def get_html(selector)
        find_element(id, selector) + _js_action("html()")
      end

      def empty(selector)
        find_element(id, selector) + _js_action("empty()")
      end

      private 

      def _jq_inverse_action(selector, markup, action)
        selector = calc_selector selector
        action = _js_camelize(action)
        "$(#{escaped(markup)}).#{action}(#{selector});"
      end      

      def _jquery_action *args, &block
        args = args.flatten    
        [id, selector, markup, action] = _extract_args(*args)
        action ||= yield if block_given?
        raise ArgumentError, "Must take action block or Symbol as last argument" unless action
        elem_action = case action
        when String
          action = _js_camelize(action)
          ".#{action};"
        else
          action = _js_camelize(action)
          _action(action, markup)
        end
        find_element(id, selector) + elem_action
      end
                
      def escaped markup
        "'#{escape(markup)}'"
      end      

      def _action name, markup        
        _js_action "#{name}(#{_escaped(markup)})"
      end

      def _js_action action
        ".#{action};"
      end

      def _js_camelize str
        str.to_s.camelize.sub(/^\w/, s[0].downcase)
      end

      # id, selector, markup, action
      def _extract_args *args
        [_extract_id(*args), _extract_selector(*args), _extract_markup(*args), _extract_action(*args)]
      end

      def _extract_id *args
        args = args.flatten
        args.size == 4 ? args.first : nil
      end

      def _extract_selector *args
        args = args.flatten
        args.size == 4 ? args[1] : args[0]
      end

      def _extract_markup(*args)
        args = args.flatten
        args.size == 4 ? args[2] : args.last
      end

      def _extract_action(*args)
        args = args.flatten
        args.size == 4 ? args.last : nil
      end

      def _apo_match? selector
        selector.to_s =~ /^_apo_/
      end

      def _calc_selector selector
        selector = _apo_selector?(selector) ? "_apo_#{selector}" : "'#{selector}'"
      end

      def _apo_selector? selector
        selector.kind_of?(Symbol) && selector.to_s[0..1] == '_'
      end
    end
  end
end
