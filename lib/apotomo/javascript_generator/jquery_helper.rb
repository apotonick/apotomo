module Apotomo
  class JavascriptGenerator
    module JqueryHelper
      def find_element id, selector        
        if id == nil || apo_selector?(selector)
          return element(selector)
        end
        element("##{id}") + ".find(\"#{selector}\")"
      end

      # - id, selector action 
      # - selector action
      def jq_action *args, action
        args = *args, nil, action
        id, selector, action = [extract_id(*args), extract_selector(*args), args.last]
        find_element(id, selector) + js_action(action)
      end
      
      def inv_markup_action(selector, markup, action)
        selector = calc_selector selector
        action = js_camelize(action)
        "jQuery(#{escaped(markup)}).#{action}(#{selector});"
      end      

      def markup_act name, *args, &block
        id, selector = extract_args *args, &block
        markup = block_given? ? yield : args.last

        find_element(id, selector) + mk_action(name, markup)        
      end

      # - id, selector, markup, action
      # - selector, markup, action
      def markup_action *args, &block
        args = args.flatten    
        id, selector, markup, action = extract_args(*args, &block)
        action ||= yield if block_given?
        raise ArgumentError, "Must take action block or Symbol as last argument" unless action
        elem_action = case action
        when String
          action = js_camelize(action)
          ".#{action};"
        else
          action = js_camelize(action)
          mk_action(action, markup)
        end
        find_element(id, selector) + elem_action
      end

      include ::ActionView::Helpers::JavaScriptHelper
        
      def escaped markup
        "\"#{escape_javascript(markup)}\""
      end      

      def mk_action name, markup
        js_action "#{name}(#{escaped(markup)})"
      end

      def js_action action
        ".#{action};"
      end

      def ns_name class_name 
        names = class_name.split('::')
        ns = names[0..-2].map {|name| js_camelize name }.join('.')
        return names.last if ns.blank?
        ns << ".#{names.last}"
      end

      def js_camelize str
        str = str.to_s
        str.camelize.sub(/^\w/, str[0].downcase)
      end

      def calc_selector selector
        selector = apo_selector?(selector) ? "_apo_#{selector}" : "\"#{selector}\""
      end

      def apo_selector? selector
        selector.kind_of?(Symbol) && selector.to_s[0..1] == '_'
      end

      def apo_match? selector
        selector.to_s =~ /^_apo_/
      end

      protected

      def element(selector)
        selector = calc_selector selector
        "jQuery(#{selector})"
      end      

      # id, selector, markup, action
      def extract_args *args, &block
        [extract_id(*args), extract_selector(*args), extract_markup(*args, &block), extract_action(*args, &block)]
      end

      def extract_id *args
        args = args.flatten
        args.size == 4 ? args.first : nil
      end

      def extract_selector *args
        args = args.flatten
        args.size == 4 ? args[1] : args[0]
      end

      def extract_markup(*args, &block)
        block_given? ? args.last : args[-2]
      end

      def extract_action(*args, &block)
        args.last unless block_given?
      end

      extend self
    end
  end
end