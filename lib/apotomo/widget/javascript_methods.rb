module Apotomo
  module JavascriptMethods
    # If you call a method corresponding to JavaScript action (#replace, #update, etc.),
    # it calls the corresponding +JavascriptGenerator+ method with rendered content.
    # The same options as #render plus an optional +selector+ to change the selector are supposed.
    #
    # If you call a method corresponding to JavaScript stuff (start with +javascript_+),
    # it calls the corresponding +JavascriptGenerator+ method with the same arguments.

    # Returns the escaped script.
    def escape_js(script)
      Apotomo.js_generator.escape(script)
    end

    # - selector, method_name, render_args
    # - method_name, render_args
    # - nil, method_name, render_args
    # - method_name
    # - nil, method_name
    def widget_call(*args)
      selector, method_name, method_args = Apotomo.js_generator.extract_args(3, args)
      Apotomo.js_generator.javascript_element_call(name, selector, method_name, Array.wrap(method_args))
    end

    [:update, :replace, :update_text, :append, :prepend, :after, :before, :wrap, :wrap_inner, :wrap_all].each do |helper_name|
      define_method helper_name do |*args, &block|
        selector = args.first.is_a?(String) ? args.shift : nil
        content = render(*args, &block)

        args = selector ? [nil, selector, [content]] : [name, nil, [content]]
        Apotomo.js_generator.send("javascript_#{helper_name}", *args)
      end
    end
  end
end
