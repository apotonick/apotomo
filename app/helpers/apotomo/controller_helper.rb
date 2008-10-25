module Apotomo
  module ControllerHelper
    
    # outgoing rendering --------------------------------------------------------
    
    
    # Renders the widget named <tt>widget_id</tt> from the ApplicationWidgetTree
    # into the controller action. Additionally activates event processing for this
    # widget and all its children.
    def act_as_widget(widget_id, model_tree_class = ::ApplicationWidgetTree)
      # create tree (new/from store)...
      
      # and pass it to the dispatched actions:
      
      if action = params['apotomo_action']  ### DISCUSS: how to find out if we're in Apotomo context?
        process_event_request(action.to_sym)
        return
      end
    
      render :text => render_widget_from_tree(widget_id, model_tree_class), 
        :layout => true
    end
    
    
    # Finds the widget named <tt>widget_id</tt> and renders it.
    def render_widget_from_tree(widget_id, model_tree_class)
      
      
      if session['apotomo_widget_tree']
        root = thaw_tree
      else
        tree = model_tree_class.new(self)
        root = tree.draw_tree
      end
      
      content = root.find_by_id(widget_id).render_content
      #session['apotomo_widget_tree'] = root
      
      
      freeze_tree(root)
      
      
      
      return content
    end
    
    
    def render_widget(widget_id)
      render_widget_from_tree(widget_id, ::ApplicationWidgetTree)
    end
    
    def widget_event?
      params['apotomo_action']
    end
    
    def render_event_response
      action = params['apotomo_action']   ### TODO: i don't like that. why?
      process_event_request(action.to_sym)
    end
    
    
    ### TODO: put next two methods in Apotomo::Persistance or so. ---------------
    def freeze_tree_for(root, storage, controller=nil)
      # put widget structure into session:
      storage['apotomo_widget_tree'] = root # CGI::Session calls Marshal#dump on this.
      # put widget instance variables into session:
      storage['apotomo_widget_content'] = {}
      root.freeze_instance_vars_to_storage(storage['apotomo_widget_content'])
    end
    def thaw_tree_for(storage, controller)
      # get widget structure from session:
      tree = storage['apotomo_widget_tree'].root
      # set widget instance variables from session:
      tree.thaw_instance_vars_from_storage(storage['apotomo_widget_content'])
      
      tree.each do |c| c.controller = controller; end  # connect current controller to the tree.
      
      return tree
    end
    #----------------------------------------------------------------------------
    
    
    def freeze_tree(root)
      freeze_tree_for(root, session)
    end
    
    def thaw_tree
      thaw_tree_for(session, self)
    end
    
    #--
    # incoming event processing -------------------------------------------------
    #--
    
    def process_event_request(action)
      #tree      = ::ApplicationWidgetTree.new(self).draw_tree.root
      puts "restoring *dynamic*  widget_tree from session."
      
      tree = thaw_tree
      
      
      #tree = session['apotomo_widget_tree'] 
      
      
      source  = tree.find_by_id(params[:source])
      evt     = Event.new(params[:type], source.name) # type is :invoke per default.
      
      ### NOTE: this will be removed when the WidgetTree is fully dynamic.
      if evt.type == :invoke
        raise "deprecated"
        evt.data={:state => params[:state].to_sym}   
        ### FIXME: this is InvokeEvent specific and
        ### currently is only needed for explicit invoke(:some_state). 
        ### usually the next state should be found automatically.
      end
      
      
      #tree.find_by_id(params[:source]).fire(evt)
      
      processed_handlers = source.invoke_for_event(evt)
      #tree.find_by_id(params[:source]).trigger(type.to_sym)

      #session['apotomo_widget_tree'] = tree
      #puts "saving tree in session."
      freeze_tree(tree)
      
      
      
      # usually an event is reported via this controller action:
      if action == :event
        render_page_update_for(processed_handlers)      
      elsif action == :iframe2event
        #puts "IFRAME2EVENT happened!"
        render_iframe_update_for(processed_handlers)
      elsif action == :data
        render_data_for(processed_handlers)
      end
      
    end
    
    
    def render_page_update_for(processed_handlers)
      render :update do |page|
        
        processed_handlers.each do |handler|
          ### DISCUSS: i don't like that switch, but moving this behaviour into the
          ###   actual handler is too complicated, as we just need replace and exec.
          content = handler.content
          next unless content ### DISCUSS: move this decision into processed_handlers#each.

          if content.class == String
            page.replace handler.widget_id, content
          else
            page << content
          end
        end
        
      end 
    end
    
    
    def render_data_for(processed_handlers)
      #puts "returning #{processed_handlers.first.content}"
      ### TODO: what if more events have been attached, smart boy?
      render :text => processed_handlers.first.content
    end
    
    
    def render_iframe_update_for(processed_handlers)
      script = ""
    
      processed_handlers.each do |handler|
          content = handler.content
          next unless content

          if content.class == String
            script += 'Element.replace("'+handler.widget_id+'", "'+content.gsub('"', '\\\\\"').gsub("\n", "").gsub("'", "\\\\'")+'");'
            #page.replace handler.widget_id, content
          else
            ### TODO: implement me.
            raise ""
            page << content
          end
        end
    
    
      # stolen from responds_to_parent, thanks sean tradeway and you other guys!
      render :text => "<html><body><script type='text/javascript' charset='utf-8'>
          var loc = document.location;
          with(window.parent) { setTimeout(function() { window.eval('#{script}'); loc.replace('about:blank'); }, 1) } 
        </script></body></html>"
    end
  end
end
