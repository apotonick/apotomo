  module Apotomo
    module ControllerMethods
      
      attr_writer :apotomo_default_url_options
      
      def apotomo_default_url_options
        @apotomo_default_url_options ||= {}
      end
      
    
      def apotomo_root
        return @apotomo_root if @apotomo_root # should be default.
        
        # this is executed once per request:
        if thaw_tree? and session['apotomo_root']
          puts "restoring *dynamic*  widget_tree from session."
          @apotomo_root = thaw_apotomo_root
        else
          @apotomo_root = widget('apotomo/stateful_widget', :widget_content, '__root__')
          
          # mix in the application widget tree:
          ### DISCUSS: introduce flag to enable?
          ::ApplicationWidgetTree.new.draw(@apotomo_root) if Object.const_defined?("ApplicationWidgetTree")
        end
        
        @apotomo_root.controller = self
        
        return @apotomo_root
      end
      
      
      def render_event_response
        action = params['apotomo_action']   ### TODO: i don't like that. why?
        process_event_request(action.to_sym)
      end
      
      
      protected
    
      def controller; self; end
      
      def use_widget(widget)
        ### TODO: provide support for blocks in #use_widgets.
        return if apotomo_root.children.find do |w| w.name == widget.name end
        
        apotomo_root << widget
      end
      
      def use_widgets
        ### FIXME/DISCUSS: how to remember these widgets were already added?
        #yield apotomo_root
        arr = []
        yield arr
        
        apotomo_root << arr.first unless apotomo_root.children.find{|c| c.name == arr.first.name}
        #catch RuntimeError

      end
        
      def respond_to_event(type, options)
        handler = ProcEventHandler.new
        handler.proc = options[:with]
        ### TODO: pass :from => (event source).
        
        # attach once, not every request:
        apotomo_root.evt_table.add_handler_once(handler, :event_type => type)
      end
      
      
      def self.included(base) #:nodoc:
        base.class_eval do
          extend ClassMethods
        end
      end
      
      
      module ClassMethods
        def has_widgets(widget=nil)
          if block_given?
            return
          end
          
          return
        end
  
        def responds_to_event(type, options)
        end
      end
      
      
  
    # outgoing rendering --------------------------------------------------------
    
    
    # Renders the widget named <tt>widget_id</tt> from the ApplicationWidgetTree
    # into the controller action. Additionally activates event processing for this
    # widget and all its children.
    #--
    # NOTE: defaults to :layout => true
    #--
    def act_as_widget(widget_id, options={})
      # create tree (new/from store)...
      
      # and pass it to the dispatched actions:
      
      if action = widget_event?
        process_event_request(action.to_sym)
        return
      end
      
      options_for_action = {:layout => true}  # same setting as when rendering an action
      options_for_action[:layout] = options.delete(:layout) if options.key?(:layout)
      options_for_action[:text]   = render_widget_from_tree(widget_id, options)
      
      render options_for_action
    end
    
    # :process is true by default.
    def render_widget(widget_id, options={}, &block)
      process_events = options.key?(:process_events) ? options.delete(:process_events) : true
      
      if process_events
        apotomo_default_url_options[:action] = :render_event_response
      end
        
      render_widget_from_tree(widget_id, options, &block)
    end
    
    ### TODO: put it in WidgetTree or somewhere else, as it's not a controller 
    ###   helper.
    # Finds the widget named <tt>widget_id</tt> and renders it.
    def render_widget_from_tree(widget_id, opts={}, &block)      
      target  = apotomo_root.find_by_path(widget_id)
      target.opts = opts unless opts.empty?
      
      #yield target
      
      content = target.render_content &block
      
      
      freeze_apotomo_root!
      
      return content
    end
    
    
    
    
    
    
    # If true, the widget tree is reloaded during runtime, even if it was already frozen
    # before. Reloading creates and runs ApplicationWidgetTree#draw.
    # This is used in development mode when you changed the tree while the server is
    # running. Default is to <em>not</em> reload the tree.
    def redraw_tree?
      ### DISCUSS: how to set this flag from outside?
      params[:reload_tree] || false
    end
    def thaw_tree?; ! redraw_tree?; end
    
    
    def widget_event?
      params['apotomo_action']
    end
    
    
    
    
    def freeze_apotomo_root!
      session['apotomo_root']           = apotomo_root
      session['apotomo_widget_content'] = {}  ### DISCUSS: always reset the hash here?
      
      apotomo_root.freeze_instance_vars_to_storage(session['apotomo_widget_content'])
    end
    
    
    def thaw_apotomo_root
      root = session['apotomo_root']
      root.thaw_instance_vars_from_storage(session['apotomo_widget_content'])
      root
    end
    
    #--
    # incoming event processing -------------------------------------------------
    #--
    
    def process_event_request(action)
      source  = apotomo_root.find_by_id(params[:source])
      evt     = Event.new(params[:type], source) # type is :invoke per default.
      ### FIXME: let trigger handle event creation!!!
      #tree.find_by_id(params[:source]).fire(evt)
      
      processed_handlers = source.invoke_for_event(evt)
      #tree.find_by_id(params[:source]).trigger(type.to_sym)
      
      
      freeze_apotomo_root!
      
      
      
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
        
        processed_handlers.each do |item|
        (handler, content) = item
          ### DISCUSS: i don't like that switch, but moving this behaviour into the
          ###   actual handler is too complicated, as we just need replace and exec.
          #content = handler.content
          next unless content ### DISCUSS: move this decision into EventHandler#process_event_for(page).

          if content.kind_of? String
            page.replace handler.widget_id, content
          else
            page << content
          end
        end
        
      end 
    end
    
    
    def render_data_for(processed_handlers)
      ### TODO: what if more events have been attached, smart boy?
      puts "  +++++++++ page updates:"
      puts processed_handlers.inspect
      (handler, content) = processed_handlers.find {|i| i.last.size > 0}  ### FIXME: how do we know which handler to return? better check for kind_of? Data
      
      render :text => content
    end
    
    
    def render_iframe_update_for(processed_handlers)
      script = ""
    
      processed_handlers.each do |handler, content|
          #content = handler.content
          next unless content

          if content.class == String
            script += 'Element.replace("'+handler.widget_id+'", "'+content.gsub('"', '\\\\\"').gsub("\n", "").gsub("'", "\\\\'")+'");'
            #page.replace handler.widget_id, content
          else
            script += content.gsub("\n", "").gsub("'", "\\\\'")
          end
        end
      logger.info script
    
      # stolen from responds_to_parent, thanks sean tradeway and you other guys!
      render :text => "<html><body><script type='text/javascript' charset='utf-8'>
          var loc = document.location;
          with(window.parent) { setTimeout(function() { window.eval('#{script}'); loc.replace('about:blank'); }, 1) } 
        </script></body></html>"
    end
  end
end
