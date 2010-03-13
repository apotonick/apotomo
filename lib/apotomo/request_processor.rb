module Apotomo
  class RequestProcessor
    include WidgetShortcuts
    
    attr_reader :session, :root
    
    def initialize(session, options={})
      @session      = session
      @tree_flushed = false
      
      if options[:flush_tree].blank? and StatefulWidget.frozen_widget_in?(session)
        @root = StatefulWidget.thaw_from(session)
      else
        @root = flushed_root 
      end
      
      handle_version!(options[:version])
    end
    
    def flushed_root
      @tree_flushed = true
      widget('apotomo/stateful_widget', :content, 'root')
    end
    
    def handle_version!(version)
      return if version.blank?
      return if root.version == version
      
      @root = flushed_root
      @root.version = version
    end
    
    def tree_flushed?;  @tree_flushed; end
    
    ### TODO: move controller dependency to rails/merb/sinatra layer only!
    ### TODO: rename to #process_for
    def process_event_request_for(request_params, controller)
      self.root.controller = controller
      
      source = self.root.find_by_id(request_params[:source])
      
      source.fire(request_params[:type].to_sym)
      source.root.page_updates ### DISCUSS: that's another dependency.
    end
    
    # Serializes the current widget tree to the storage that was passed in the constructor.
    # Call this at the end of a request.
    def freeze!
      root.freeze_to(@session)
    end
    
    # Renders the widget named <tt>widget_id</tt>, passing optional <tt>opts</tt> and a block to it.
    # Use this in your #render_widget wrapper.
    def render_widget_for(widget_id, opts, controller, &block)
      if widget_id.kind_of?(StatefulWidget)
        widget = widget_id
      else
        widget = root.find_by_id(widget_id)
        raise "Couldn't render non-existent widget `#{widget_id}`" unless widget
      end
      
      
      ### TODO: pass options in invoke.
      widget.opts = opts unless opts.empty?
      
      ### TODO: move controller dependency to rails/merb/sinatra layer only!
      widget.root.controller = controller
      
      widget.invoke(&block)
    end
  end
end