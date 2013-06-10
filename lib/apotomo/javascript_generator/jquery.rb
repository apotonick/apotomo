module Apotomo
  class JavascriptGenerator
    module Jquery

      def jquery
      end

      # Wraps the args in a statement according to your +Apotomo.js_framework+ setting.
      #
      # Example for #replace (with <tt>Apotomo.js_framework = :jquery</tt>):
      #
      #   replace "squeak"
      #   #=> "jQuery(\"#mouse\").replaceWith(\"squeak\")"
      #
      # You may pass a selector and pass options to render here, as well.
      #
      #   replace "#jerry h1", "squeak"
      #   #=> "jQuery(\"#jerry h1\").replaceWith(\"squeak\")"

      # - id, selector, method_args
      # - selector, method_args
      # - nil, selector, method_args

      def javascript_update(*args, &block)
        id, selector, markup = *extract_args(3, *args)
        javascript_element_call(id, selector, :html, Array.wrap(markup), &block)
      end
      alias_method :javascript_html, :javascript_update

      def javascript_replace(*args, &block)
        id, selector, markup = *extract_args(3, *args)
        javascript_element_call(id, selector, :replace_with, Array.wrap(markup), &block)
      end
      alias_method :javascript_replace_with, :javascript_replace

      [:update_text, :append, :prepend, :after, :before, :wrap, :wrap_inner, :wrap_all].each do |method_name|
        define_method "javascript_#{method_name}" do |*args|
          id, selector, markup = args.shift, *extract_args(2, args)
          javascript_element_call(id, selector, method_name, Array.wrap(markup), &block)
        end
      end

      [:unwrap, :remove, :attr, :prop, :val, :empty].each do |method_name|
        define_method "javascript_#{method_name}" do |*args|
          id, selector, method_args = *extract_args(3, *args)
          javascript_element_call(id, selector, method_name, Array.wrap(method_args), &block)
        end
      end

      [:add_class, :remove_class, :toggle_class].each do |method_name|
        define_method "javascript_#{method_name}" do |*args|
          id, selector, classes = *extract_args(3, *args).flatten.join(' ')
          javascript_element_call(id, selector, method_name, Array.wrap(classes_str), &block)
        end
        alias_method "javascript_#{method_name}es", "javascript_#{method_name}"
      end
    end


    def javascript_find_element_by_selector(selector)
      %Q{#{jquery_namespace}("#{selector}")}
    end

    def javascript_find_element_by_id(id)
      javascript_find_element_by_selector(javascript_selector_by_id(id))
    end

    alias_method :javascript_element, :javascript_find_element_by_id

    # - selector, action
    # - nil, action
    # - selector, nil
    def javascript_find_element_selector(id, selector)
      if id
        if selector
          javascript_find_element_by_id(id) + javascript_action(%Q{.find("#{selector}")})
        else
          javascript_find_element_by_id(id)
        end
      else
        javascript_find_element_by_selector(selector)
      end
    end

    # - id, selector, action
    # - selector, action
    # - nil, selector, action
    def javascript_element_action(*args, action)
      id, selector = *extract_args(2, args)
      javascript_find_element_selector(id, selector) + javascript_action(action)
    end

    # - id, selector, method_name, method_args
    # - selector, method_name, method_args
    # - nil, selector, method_name, method_args
    # - method_name, method_args
    # - nil, nil, method_name, method_args
    def javascript_element_call(*args)
      id, selector, method_name, method_args = *extract_args(4, *args)
      javascript_find_element_selector(id, selector) + javascript_call(method_name, *method_args)
    end

    private

    def jquery_namespace
      "jQuery"
    end
  end
end
