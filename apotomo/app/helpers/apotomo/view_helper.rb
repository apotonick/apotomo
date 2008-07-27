module Apotomo
  module ViewHelper
    
    
    def target_widget_for(widget_id=false)
      widget_id ? current_tree.find_by_id(widget_id) : Apotomo::StatefulWidget.current_widget
    end
    
    
    def current_tree
      Apotomo::StatefulWidget.current_widget.root
    end
    
    
    # public methods ------------------------------------------------------------
    
    # Creates a link to the event controller and the targeted widget.
    # The AJAX request triggered by clicking this link will result in an Apotomo event
    # with the specified :source and :type, along with arbitrary parameters in way.
    # Reserved options for way:
    #   :source
    #   :type
    ### TODO: discuss the request cycle behaviour.
    def link_to_event(title, way={}, html_options={})
      source_id = way[:source]
      addr      = address_to_remote_widget(source_id, way)
      
      link_to_remote(title, {:url => addr}, html_options)
    end
    
    # Returns the address hash to the event controller and the targeted widget.
    # Can be passed to #url_for.
    def address_to_remote_widget(widget_id=false ,way={}) 
      target = target_widget_for(widget_id)
      way.merge({:action => 'event', :controller => 'apotomo', :source => target.name})
    end
    
    
    # Creates a bookmarkable link to a widget. When clicked, the whole application
    # state ("page") is reloaded without AJAX.
    def static_link_to_widget(title, widget_id=false, way={}, html_options={})
      target = target_widget_for(widget_id)
      way.delete(:static) ### DISCUSS: clean up at central place.
      
      link_to(title, target.address(way), html_options)
    end
    
    
    # the standard way to get a link tag referencing a widget in the tree.
    ### DISCUSS: rename to #link_to_invoke ?
    def link_to_widget(title, widget_id=false, way={}, html_options={})
      if way[:static]
        return static_link_to_widget(title, widget_id, way, html_options)
      end
      
      
      way[:source] = widget_id
      
      link_to_event(title, way, html_options)
    end
    
    
    # Creates a form tag to the event controller and the targeted widget.
    # The behaviour of the submit request is discussed in link_to_event.
    # 
    # Only provide +widget_id+ if you want another source widget for the resulting 
    # Apotomo event than the current widget rendering the form.
    ### DISCUSS: deprecate widget_id.
    def form_to_widget(way={}, widget_id=false, html_options={})
      addr = address_to_remote_widget(widget_id, way)
      
      form_remote_tag({:url => addr})
    end
    
    
    # Creates a form tag to the event controller and the targeted widget.
    # The behaviour of the submit request is discussed in link_to_event.
    # 
    def form_to_event(way={}, html_options={})
      addr = address_to_remote_widget(way[:source], way)
      
      form_remote_tag({:url => addr})
    end
    
   end
  
  

  
end
