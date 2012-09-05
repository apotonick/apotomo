require 'action_view/helpers/javascript_helper'
require 'apotomo/javascript_generator/jquery_helper'

module Apotomo
  class JavascriptGenerator
    autoload :JqueryHelper, 'apotomo/javascript_generator/jquery_helper'

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
        selector = jq_helper.calc_selector selector
        "$(#{selector})"
      end

      def update(*args, &block)
        jq_helper.markup_act :html, *args, &block
      end

      def replace(*args, &block)
        jq_helper.markup_act :replaceWith, *args, &block
      end        

      def update_id(id, markup);  update("##{id}", markup); end
      def replace_id(id, markup); replace("##{id}", markup); end

      def selector_for var, id, selector
        raise ArgumentError, "Must not be an _apo_ selector here: #{selector}" if jq_helper.apo_match?(selector)
        "var _apo_#{var} = " + element("##{id}") + ".find(\"#{selector}\");"
      end

      [:replace_all, :prepend_to, :append_to].each do |name|
        define_method name do |selector, markup|
          jq_helper.inv_markup_action selector, markup, name.to_sym
        end
      end

      [:update_text, :append, :prepend, :after, :before, :wrap, :wrap_inner, :wrap_all].each do |name|
        define_method name do |args|      
          jq_helper.markup_action *args, name
        end
      end

      def unwrap *args
        jq_helper.markup_action *args, 'unwrap()'
      end    

      def remove *args
        jq_helper.markup_action *args, 'remove()'
      end

      def remove_class(id, selector, *classes)
        classes = classes.flatten.join(' ')
        jq_helper.jq_action id, selector, "removeClass('#{classes}')"
      end
      alias_method :remove_classes, :remove_class

      def add_class(id, selector, *classes)
        classes = classes.flatten.join(' ')
        jq_helper.jq_action id, selector, "addClass('#{classes}')"
      end
      alias_method :add_classes, :add_class

      def toggle_class(id, selector, *classes)
        classes = classes.flatten.join(' ')
        jq_helper.jq_action id, selector, "toggleClass('#{classes}')"
      end
      alias_method :toggle_classes, :toggle_class

      def toggle_class_fun(id, selector, fun)        
        jq_helper.jq_action id, selector, "toggleClass(function() {#{fun}})"
      end

      def get_attr(id, selector, name)
        jq_helper.jq_action id, selector, "attr('#{name}')"
      end

      def get_prop(id, selector, name)        
        jq_helper.jq_action id, selector, "prop('#{name}')"
      end

      def get_val id, selector        
        jq_helper.jq_action id, selector, "val()"
      end

      def get_html(id, selector)
        jq_helper.jq_action id, selector, "html()"
      end

      def empty(id, selector)
        jq_helper.jq_action id, selector, "empty()"
      end

      private 

      def jq_helper
        JqueryHelper
      end
    end
  end
end
