module Apotomo
  module ViewHelper
    # Generates the JavaScript code to report an event of <tt>:type</tt> to Apotomo with AJAX.
    # As always per default the event source is the currently rendered widget.
    # Internally this method just uses <tt>remote_function</tt> for JS output.
    #
    # Example:
    # 
    #   <%= image_tag "cheese.png", :onMouseover => trigger_event(:type => :mouseAlarm) %>
    #
    # will trigger the event <tt>:mouseAlarm</tt> when moving the mouse over the cheese image.
    def trigger_event(options)
      remote_function(:url => @controller.apotomo_address_for(@cell, options))
    end
    
    # Creates a link that triggers an event via AJAX.
    # This link will <em>only</em> work in JavaScript-able browsers.
    #
    # Note that the link is created using #link_to_remote.
    #
    # See StatefulWidget::address_for_event for options.
    def link_to_event(title, options, html_options={})
      link_to_remote(title, {:url => @controller.apotomo_address_for(@cell, options)}, html_options)
    end
    
    # Creates a form tag that triggers an event via AJAX when submitted.
    # See StatefulWidget::address_for_event for options.
    #
    # The values of form elements are available via StatefulWidget#param.
    def form_to_event(options, html_options={}, &block)
      form_remote_tag({:url => @controller.apotomo_address_for(@cell, options), :html => html_options}, &block)
    end
    
    def update_url(fragment)
      'SWFAddress.setValue("' + fragment + '");'
    end
    
    ### TODO: test me.
    ### DISCUSS: rename to rendered_children ?
    def content
      @rendered_children.collect{|e| e.last}.join("\n")
    end
    
   end

end
