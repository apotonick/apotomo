module Apotomo
  class JavascriptGenerator
    module JqueryHelper
      def find_element id, selector        
        if id == nil || apo_selector?(selector)
          return element(selector)
        end
        element("##{id}") + ".find('#{selector}')"
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
        "$(#{escaped(markup)}).#{action}(#{selector});"
      end      

      def markup_action *args, &block
        args = args.flatten    
        id, selector, markup, action = extract_args(*args)
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
                
      def escaped markup
        "'#{escape(markup)}'"
      end      

      def mk_action name, markup        
        js_action "#{name}(#{escaped(markup)})"
      end

      def js_action action
        ".#{action};"
      end

      def js_camelize str
        str.to_s.camelize.sub(/^\w/, s[0].downcase)
      end

      def calc_selector selector
        selector = apo_selector?(selector) ? "_apo_#{selector}" : "'#{selector}'"
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
        "$(#{selector})"
      end      

      # id, selector, markup, action
      def extract_args *args
        [extract_id(*args), extract_selector(*args), extract_markup(*args), extract_action(*args)]
      end

      def extract_id *args
        args = args.flatten
        args.size == 4 ? args.first : nil
      end

      def extract_selector *args
        args = args.flatten
        args.size == 4 ? args[1] : args[0]
      end

      def extract_markup(*args)
        args = args.flatten
        args.size == 4 ? args[2] : args.last
      end

      def extract_action(*args)
        args = args.flatten
        args.size == 4 ? args.last : nil
      end

      extend self
    end
  end
end