module Apotomo
  module JavascriptMethods
    # Returns the escaped script.
    def escape_js(script)
      Apotomo.js_generator.escape(script)
    end
    
    # Wraps the rendered content in a replace statement according to your +Apotomo.js_framework+ setting.
    # Received the same options as #render plus an optional +selector+ to change the selector.
    #
    # Example (with <tt>Apotomo.js_framework = :jquery</tt>):
    #
    #   def hungry
    #     replace 
    #
    # will render the current state's view and wrap it like
    #
    #   "$(\"#mouse\").replaceWith(\"<div id=\\\"mouse\\\">hungry!<\\/div>\")"
    #
    # You may pass a selector and pass options to render here, as well.
    #
    #     replace "#jerry h1", :view => :squeak 
    #     #=> "$(\"#jerry h1\").replaceWith(\"<div id=\\\"mouse\\\">squeak!<\\/div>\")"
    def replace(*args)
      wrap_in_javascript_for(:replace, *args)
    end
    
    # Same as #replace except that the content is wrapped in an update statement.
    #
    # Example for +:jquery+:
    #
    #   update :view => :peek
    #   #=> "$(\"#mouse\").html(\"looking...")"
    def update(*args)
      wrap_in_javascript_for(:update, *args)
    end

    # Instruct the browser to perform a redirect to the specified url.    
    # 
    # Example:
    #
    #   redirect_to course_path(@course.id)
    #   #=> "window.location.replace(\"davinci.dev/courses/4f592ee4b5a482327b000008\");"    
    def redirect_to(url)
      render :text => "window.location.replace(\"#{url}\");"
    end    
    
  private
    def wrap_in_javascript_for(mode, *args)
      selector  = args.first.is_a?(String) ? args.shift : false
      content   = render(*args)
      
      selector ? 
        Apotomo.js_generator.send(mode, selector, content) :    # replace(:twitter)
        Apotomo.js_generator.send("#{mode}_id", name, content)  # replace_id(:twitter)
    end
  end
end
