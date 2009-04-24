module Apotomo
  module ViewHelper
    
    # ### TODO: discuss the request-event cycle.
    # ### TODO: explain that an 'address' to a widget is a set of parameters needed to
    #   display the targeted widget when re-rendering the screen.
    
    def target_widget_for(widget_id=false)
      widget_id ? current_tree.find_by_path(widget_id) : @cell
    end
    
    
    def current_tree
      @cell.root
    end
    
    
    
        
    # Returns the address hash to the event controller and the targeted widget.
    #
    # Reserved options for <tt>way</tt>:
    #   :source   explicitly specifies an event source.
    #             The default is to take the currently rendered widget as source.
    #   :type     explicitly specifies the event type.
    #             The default is :invoke  ### FIXME: more writing here!
    #
    # Any other option will be directly passed into the address hash and will be 
    # available via StatefulWidget#param in the widget.
    #
    # Can be passed to #url_for.
    # 
    # Example:
    #   <%= address_to_event :type => :click, :item_id => 9 %>
    # will result in an address that triggers a <tt>:click</tt> event from the current
    # widget and also provides the parameter <tt>:item_id</tt>.
    def address_to_event(way={}, action='event')
      # only set param in address when there really is one provided as default or as arg.
      # otherwise, let #url_for handle this.
      [:controller, :action].each do |param|
        next unless value = @controller.apotomo_default_url_options[param]
        way[param] ||= value # args in way have precedence.
      end
      
      target = target_widget_for(way[:source])
      
      # handle implicit :invoke event:
      if ! way[:type]
        attach_invoke_handler_to(target, way) 
      end
      
      
      way.merge({ :apotomo_action   => action,
                  :source           => target.name })
    end
    
    def type_uid_for(target, way)
      "#{target.name}_#{way[:state]}".to_sym
    end
    
    
    # Attaches an event handler to the target widget which will allow send
    # the widget to another state ("invoking"). This happens automatically when
    # omitting a <tt>:type</tt> argument or setting it to <tt>:invoke</tt>.
    #
    # You can set the new state of the targeted widget by
    # providing the <tt>:state</tt> argument in link_to_event, form_to_event or
    # address_to_event. For example
    #   
    #   form_to_event(:state => :next_state)
    #
    # would send the current widget (which rendered the form) to its 
    # <tt>:next_state</tt> state when the form is submitted.
    #
    # You shouldn't call this method since it is automatically run in link_to_event,
    # form_to_event or address_to_event.
    def attach_invoke_handler_to(target, way)
      type_uid =  type_uid_for(target, way)
        
      # attach invoke handler to target:
      target.peek(type_uid, target.name, way[:state])

      #puts target.evt_table.inspect
      way[:type] = type_uid
      way.delete(:state)  ### DISCUSS: do that in type_uid_for ?
    end
    
    
    # Creates a link that triggers an event via AJAX.
    # This link will <em>only</em> work in JavaScript-able browsers.
    #
    # Note that the link is created using #link_to_remote.
    #
    # See #address_to_event for options for <tt>way</tt>
    #--
    ### TODO: discuss the request cycle behaviour.
    #--
    def link_to_event(title, way={}, html_options={})
      addr  = address_to_event(way)
      
      link_to_remote(title, {:url => addr}, html_options)
    end
    
    
    # Creates a form tag that triggers an event via AJAX when submitted.
    # See #address_to_event for options for <tt>way</tt>.
    #
    # The values of form elements are available via StatefulWidget#param.
    # 
    # If you want to <b>upload files</b> with this form, set 
    # <tt>html_options{:multipart => true}</tt>. Apotomo will do the rest to provide 
    # you with an AJAX form that can upload files.
    # 
    # See also #form_to_event_via_iframe.
    #--
    ### TODO: test me.
    #--
    def form_to_event(way={}, html_options={}, &block)
      return form_to_event_via_iframe(way, html_options, &block) if html_options[:multipart]
      
      addr = address_to_event(way)
      
      form_remote_tag({:url => addr, :html => html_options}, &block)
    end
    
    # Creates a form that submits itself via an iFrame and executes the response
    # in the parent window. This is currently needed to upload files via AJAX.
    # 
    # You shouldn't call this directly, better call #form_to_event and set 
    # <tt>:multipart</tt> to <tt>true</tt>, stay forward-compatible.
    #--
    ### TODO: test me.
    #--
    def form_to_event_via_iframe(way={}, html_options={}, &block)
      addr = address_to_event(way, :iframe2event)
      
      '<iframe id="'+iframe_id+'" name="'+iframe_id+'" style="width:1px;height:1px;border:0px" src="about:blank"></iframe>'+
      
      form_tag(addr, html_options.merge!(:target => iframe_id), &block)
    end
    
    
    
    # Creates a dynamic - but still bookmarkable - link to an application state.
    # Both browsers with JavaScript turned on, or turned off (like search bots)
    # will be able to follow this link.
    #
    # If clicked with JS turned on, an AJAX event will be triggered which redraws the
    # screen to switch the application state (eg to change to another subtree).
    # In non-JS browsers the whole page will simply reload, being in exactly the same 
    # state as if the browser had JS turned on.
    def link_to_widget(title, widget_id=false, way={}, html_options={})
      link_to_app_state(title, widget_id, way, html_options)
    end
    
    
    # Creates a bookmarkable link to an application state, without any JavaScript. 
    # When clicked, the whole application ("page") is reloaded without AJAX.
    # 
    # Note that the link is created using #link_to.
    #
    # This allows links that contain enough state information to display even deeply
    # nested widgets, e.g. a form within a TabWidget that itself is under a
    # ChildSwitchWidget.
    def static_link_to_widget(title, widget_id=false, way={}, html_options={})
      target = target_widget_for(widget_id)
      
      link_to(title, target.address(way), html_options)
    end
    
    
    
    def link_to_app_state(title, widget_id=false, way={}, html_options={})
      target = target_widget_for(widget_id)
      
      # address to application state:
      widget_address = target.address(way)
            
      # the static link is simply the routed widget's address:
      html_options[:href] = url_for(widget_address)
      
      ### TODO/DISCUSS: currently we have to manually attach a :redrawApp handler to
      ###   the respective on-screen "root" widget.
      evt_address = address_to_event({:type => :redrawApp}.merge!(widget_address) )
      
      link_to_remote(title, {:url=>evt_address}, html_options)
    end
    
    def iframe_id
      'apotomo_iframe'
    end
    
    
    ### TODO: test me.
    def content
      @rendered_children.collect{|e| e.last}.join("\n")
    end
    
   end

end
