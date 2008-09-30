module Apotomo
  module ViewHelper
    
    
    def target_widget_for(widget_id=false)
      widget_id ? current_tree.find_by_id(widget_id) : Apotomo::StatefulWidget.current_widget
    end
    
    
    def current_tree
      Apotomo::StatefulWidget.current_widget.root
    end
    
    
    # public methods ------------------------------------------------------------
    
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
      target = target_widget_for(way[:source])
      
      
      # handle implicit :invoke event:
      if ! way[:type]
        type_uid =  type_uid_for(target, way)
        
        # attach invoke handler to target:
        target.peek(type_uid, target.name, way[:state])
        
        #puts target.evt_table.inspect
        way[:type] = type_uid
        way.delete(:state)  ### DISCUSS: do that in type_uid_for ?
      end
      
      
      way.merge({ #:action     => action,
                  :apotomo_action     => action,
                  #:controller => 'apotomo', 
                  :source => target.name})
    end
    
    def type_uid_for(target, way)
      "#{target.name}_#{way[:state]}".to_sym
    end
        
    
    # Creates a link that triggers an event via AJAX.
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
    
    
    
    # Creates a bookmarkable link to a widget. See #static_link_to_widget.
    def link_to_widget(title, widget_id=false, way={}, html_options={})
      static_link_to_widget(title, widget_id, way, html_options)
    end
    
    
    # Creates a bookmarkable link to a widget. When clicked, the whole application
    # state ("page") is reloaded without AJAX.
    # 
    # This allows links that contain enough state information to display even deeply
    # nested widgets, e.g. a form within a TabWidget that itself is under a
    # ChildSwitchWidget.
    def static_link_to_widget(title, widget_id=false, way={}, html_options={})
      target = target_widget_for(widget_id)
      way.delete(:static)
      
      link_to(title, target.address(way), html_options)
    end
    
    
    def iframe_id
      'apotomo_iframe'
    end
    
    
    # explicit _for_widget methods ----------------------------------------------
    
    
    # Same as #address_to_event, for people who like to explicity set <tt>:source</tt> via
    # the <tt>widget_id</tt> parameter.
    def address_to_event_for_widget(widget_id=false, way={})
      way[:source] = widget_id
      address_to_event(way)
    end
    
    
   end

end
