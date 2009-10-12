  module Apotomo
    module ControllerMethods
      include WidgetShortcuts
      
      
      attr_writer :apotomo_default_url_options
      
      def apotomo_default_url_options
        @apotomo_default_url_options ||= {}
      end
      
    
      def apotomo_root
        return @apotomo_root if @apotomo_root # should be default, after first call.
        
        # this is executed once per request:
        if session['apotomo_root']
          puts "restoring *dynamic*  widget_tree from session."
          @apotomo_root = thaw_apotomo_root
        else
          @apotomo_root = widget('apotomo/stateful_widget', :widget_content, '__root__')
        end
        
        add_unbound_procs_to(@apotomo_root) # add #has_widgets blocks.
        
        ### DISCUSS: passing controller in #invoke sucks. passing in widget constructor sucks. but setting it here sucks as well. i hate controllers.
        @apotomo_root.controller = self
        
        return @apotomo_root
      end
      
      
      def render_event_response
        action = params['apotomo_action']   ### TODO: i don't like that. why?
        process_event_request(action.to_sym)
      end
      
      
      def executable_javascript?(content)
        content.kind_of? JavascriptSource
      end
      
      
      protected
      
      # Makes the passed +widget+ instance a persistant (stateful!) widget by
      # adding it to +root+.
      def use_widget(widget)
        return if apotomo_root.find do |w| w.name == widget.name end
        
        apotomo_root << widget
      end
      
      # Yields the root widget for manipulating the widget tree in a controller action.
      # Note that this method is executed once per session and not in every request.
      #
      # Example:
      #   def login
      #     use_widgets do |root|
      #       root << cell(:login, :form, 'login_box')
      #     end
      #
      #     @box = render_widget 'login_box'
      #   end
      def use_widgets(&block)
        return if bound_procs.include?(block)
        
        
        yield apotomo_root    # yield, and..
        bound_procs << block  # remember the proc.
      end
      
      
      def respond_to_event(type, options)
        handler = ProcEventHandler.new
        handler.proc = options[:with]
        ### TODO: pass :from => (event source).
        
        # attach once, not every request:
        apotomo_root.evt_table.add_handler_once(handler, :event_type => type)
      end
      
      
      def add_unbound_procs_to(root)
        collect_unbound_has_widgets_blocks.each do |proc|
          proc.call(root)       # yield, and..
          bound_procs << (proc) # remember the proc.
        end
      end
      
      def collect_unbound_has_widgets_blocks
        ### TODO: implement has_widgets_blocks - bound_procs.
        self.class.has_widgets_blocks.reject do |proc|
          bound_procs.include?(proc)
        end || Array.new
      end
      
      
      def bound_procs
        session[:apotomo_bound_procs] ||= ProcHash.new  ### DISCUSS: the session dependency sucks.
      end
      
      def reset_bound_procs
        session[:apotomo_bound_procs] = nil
      end
      
      
      def self.included(base) #:nodoc:
        base.class_eval do
          extend ClassMethods
          extend WidgetShortcuts
          
          class_inheritable_array :has_widgets_blocks
          base.has_widgets_blocks = []
          
          before_filter :apotomo_handle_flushing
        end
      end
      
    private
      def apotomo_handle_flushing
        ### TODO: check if flushing is allowed at all.
        flush_widget_tree unless thaw_tree?
      end
      
      def flush_widget_tree
        reset_bound_procs   # make has_widgets blocks work again.
        session['apotomo_widget_content'] = {}  ### TODO: implement #reset_widget_store
        session['apotomo_root']           = nil ### TODO: implement #reset_widget_tree
      end
    
      
    public  ### FIXME: provide proper access levels for ALL methods.
      
      module ClassMethods
        # Same as #use_widgets but to be used in controller class context.
        # As soon as the class is compiled, the widget tree manipulation will take effects.
        # Also note that this method is executed only once per session.
        # Example:
        #
        #   class HunterController < ApplicationController::Base
        #     include Apotomo::ControllerMethods
        #     
        #     has_widgets do |root|
        #       root << cell(:bear_trap, :charged, 'nasty_trap')
        #     end
        #     
        #     def trap_bears
        #       @box = render_widget 'nasty_trap'
        #     end
        def has_widgets(&block)
          has_widgets_blocks << block
        end
        
        ### DISCUSS: do we need that?
        def responds_to_event(type, options)
        end
      end
      
      
      class ProcHash < Array
        def id_for_proc(proc)
          proc.to_s.split('@').last
        end
      
        def <<(proc)
          super(id_for_proc(proc))
        end
        
        def include?(proc)
          super(id_for_proc(proc))
        end
      end
      
    # outgoing rendering --------------------------------------------------------
    
    
    # Renders the widget named <tt>widget_id</tt> from the ApplicationWidgetTree
    # into the controller action. Additionally activates event processing for this
    # widget and all its children.
    #--
    # NOTE: defaults to :layout => true
    # DISCUSS: remove #act_as_widget in favour of less confusion?
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
      options_for_action[:text]   = render_widget_for(widget_id, options)
      
      render options_for_action
    end
    
    # :process is true by default.
    def render_widget(widget, options={}, &block)
      process_events = options.key?(:process_events) ? options.delete(:process_events) : true
      
      if process_events
        apotomo_default_url_options[:action] = :render_event_response
      end
      
      
      render_widget_for(widget, options, &block)
    end
    
    ### TODO: put it in WidgetTree or somewhere else, as it's not a controller 
    ###   helper.
    # Finds the widget named <tt>widget_id</tt> and renders it.
    def render_widget_for(widget_id, opts={}, &block)      
      ### DISCUSS: let user pass widget OR/and widget_id ?
      if widget_id.kind_of? Apotomo::StatefulWidget
        widget = widget_id
      else
        widget = apotomo_root.find_by_id(widget_id)
        raise "Couldn't render non-existant widget `#{widget_id}`" unless widget
      end
      
      
      
      widget.opts = opts unless opts.empty?
      
      #yield target
      
      content = widget.render_content &block
      
      ### DISCUSS: this happens multiple times when calling #render_widget more than once!
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
      evt     = Apotomo::Event.new(params[:type], source) # type is :invoke per default.
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

          if controller.executable_javascript?(content)
            page << content
          else
            page.replace handler.widget_id, content
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
