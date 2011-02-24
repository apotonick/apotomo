module Apotomo
  module JavascriptMethods
    # Wraps the rendered content in a replace statement targeted at your +Apotomo.js_framework+ setting.
    # Use +:selector+ to change the selector.
    #
    # Example:
    #
    # Assuming you set 
    #   Apotomo.js_framework = :jquery
    #
    # and call replace in a state
    #
    #   replace :view => :squeak, :selector => "div#mouse"
    #   #=> "$(\"div#mouse\").replaceWith(\"<div id=\\\"mum\\\">squeak!<\\/div>\")"
    def replace(*args)
      wrap_in_javascript_for(:replace, *args)
    end
    
    # Same as replace except that the content is wrapped in an update statement.
    #
    # Example for +:jquery+:
    #
    #   update :view => :squeak
    #   #=> "$(\"mum\").html(\"<div id=\\\"mum\\\">squeak!<\\/div>\")"
    def update(*args)
      wrap_in_javascript_for(:update, *args)
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
