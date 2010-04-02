module Apotomo
  module Rails
    module ViewHelper
      # Generates the JavaScript code to report an event of <tt>type</tt> to Apotomo with AJAX.
      # As always per default the event source is the currently rendered widget.
      # Internally this method just uses <tt>remote_function</tt> for JS output.
      #
      # Example:
      # 
      #   <%= image_tag "cheese.png", :onMouseover => trigger_event(:mouseAlarm) %>
      #
      # will trigger the event <tt>:mouseAlarm</tt> when moving the mouse over the cheese image.
      def trigger_event(type, options={})
        remote_function(:url => @controller.compute_event_address_for(@cell, type, options))
      end
      
      # Creates a link that triggers an event via AJAX.
      # This link will <em>only</em> work in JavaScript-able browsers.
      #
      # Note that the link is created using #link_to_remote.
      def link_to_event(title, type, options={}, html_options={})
        link_to_remote(title, {:url => @controller.compute_event_address_for(@cell, type, options)}, html_options)
      end
      
      # Creates a form tag that triggers an event via AJAX when submitted.
      # See StatefulWidget::address_for_event for options.
      #
      # The values of form elements are available via StatefulWidget#param.
      def form_to_event(type, options={}, html_options={}, &block)
        return multipart_form_to_event(type, options, html_options, &block) if options.delete(:multipart)
        
        form_remote_tag({:url => @controller.compute_event_address_for(@cell, type, options), :html => html_options}, &block)
      end
      
      # Creates a form that submits itself via an iFrame and executes the response
      # in the parent window. This is needed to upload files via AJAX.
      #
      # Better call <tt>#form_to_event :multipart => true</tt> and stay forward-compatible.
      def multipart_form_to_event(type, options={}, html_options={}, &block)
        options.reverse_merge!      :apotomo_iframe => true
        html_options.reverse_merge! :target         => :apotomo_iframe, :multipart => true
        
        # i hate rails:
        concat('<iframe id="apotomo_iframe" name="apotomo_iframe" style="display: none;"></iframe>') << form_tag(@controller.compute_event_address_for(@cell, type, options), html_options, &block)
      end
      
      # Returns the url to trigger a +type+ event from the currently rendered widget.
      # The source can be changed with +:source+. Additional +options+ will be appended to the query string.
      #
      # Note that this method will use the framework's internal routing if available (e.g. #url_for in Rails).
      #
      # Example:
      #   url_for_event(:paginate, :page => 2)
      #   #=> http://apotomo.de/mouse/process_event_request?type=paginate&source=mouse&page=2
      def url_for_event(type, options={})
        url_for @controller.compute_event_address_for(@cell, type, options)
      end
      
      ### TODO: test me.
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
end
