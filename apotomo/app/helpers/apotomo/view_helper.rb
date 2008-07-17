module Apotomo
  module ViewHelper
    
    
    def target_widget_for(widget_id=false)
      widget_id ? current_tree.find_by_id(widget_id) : Apotomo::StatefulWidget.current_widget
    end
    
    
    ### DISCUSS: find the tree via current_widget, 
    ### pass the tree obj, or what?
    def current_tree
      Apotomo::StatefulWidget.current_widget.root
    end
    
    
    ### TODO: deprecate.
    ### DISCUSS: really?
    #def link_to_event(title, source_id=false, way={}, html_options={})
    def link_to_event(title, way={}, html_options={})
      source_id = way[:source] || false
      ### TODO: filter out :source from way!
      addr = address_to_remote_widget(source_id, way)
      
      link_to_remote(title, {:url => addr}, html_options)
    end
    
    
    # public methods ------------------------------------------------------------
    
    def address_to_remote_widget(widget_id=false ,way={}) 
      target = target_widget_for(widget_id)
        ### TODO: utilize Apotomo::Addressing.
      #way.merge({:action => :event_gateway, :controller => 'apotomo', :widget_id => target.name})
      way.merge({:action => :event, :controller => 'apotomo', :source => target.name})
    end
    
    
    # the standard way to get a link tag referencing a widget in the tree.
    ### DISCUSS: rename to #link_to_invoke ?
    def link_to_widget(title, widget_id=false, way={}, html_options={})
      way[:type] = :invoke  ### FIXME: not necessary, since this is set in the apotomo_controller by default.
      #link_to_event(title, widget_id, way, html_options)
      way[:source] = widget_id
      
      link_to_event(title, way, html_options)
    end
    
    
    # the standard way to get a form tag referencing a widget in the tree.
    def form_to_widget(way={}, widget_id=false, html_options={})
    #def form_to_event()
      way[:type] = :invoke
      addr = address_to_remote_widget(widget_id, way)
      
      form_remote_tag({:url => addr})
    end
    
   end  
  
  

  
end
