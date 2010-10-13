module Apotomo
  class RequestProcessor
    include WidgetShortcuts
    
    attr_reader :session, :root
    
    def initialize(controller, session, options={}, has_widgets_blocks=[])
      @session              = session
      @widgets_flushed      = false
      
      @root = widget('apotomo/widget', 'root')
      @root.controller = controller
      
      attach_stateless_blocks_for(has_widgets_blocks, @root, controller)
      
      if options[:flush_widgets].blank? and ::Apotomo::StatefulWidget.frozen_widget_in?(session)  
        @root = ::Apotomo::StatefulWidget.thaw_for(session, @root)
      else
        #@root = flushed_root
        
        flushed_root  ### FIXME: set internal mode to flushed 
      end
      
      #handle_version!(options[:version])
    end
    
    def attach_stateless_blocks_for(blocks, root, controller)
      blocks.each do |blk|
        if blk.arity == 1
          #blk.call(root) and next # fixes misbehaviour in ruby 1.8.
          controller.instance_exec(root, &blk) and next
        end
        ### FIXME: use Widget.has_widgets func.
        controller.instance_exec(root, controller, &blk)  
      end
    end
    
    
    def flushed_root
      StatefulWidget.flush_storage(session)
      @widgets_flushed = true
      #widget('apotomo/widget', 'root')
    end
    
    ### DISCUSS: do we need the version feature, or should we push that into user code?
    def handle_version!(version)
      return if version.blank?
      return if root.version == version
      
      @root = flushed_root
      @root.version = version
    end
    
    def widgets_flushed?;  @widgets_flushed; end
    
    # Fires the request event in the widget tree and collects the rendered page updates.
    def process_for(request_params)
      source = self.root.find_widget(request_params[:source]) or raise "Source #{request_params[:source].inspect} non-existent."
      
      source.fire(request_params[:type].to_sym)
      source.root.page_updates ### DISCUSS: that's another dependency.
    end
    
    ### FIXME: remove me!
    def render_page_updates(page_updates)
      page_updates.join("\n")
    end
    
    # Serializes the current widget tree to the storage that was passed in the constructor.
    # Call this at the end of a request.
    def freeze!
      Apotomo::StatefulWidget.freeze_for(@session, root)
    end
    
    # Renders the widget named <tt>widget_id</tt>, passing optional <tt>opts</tt> and a block to it.
    # Use this in your #render_widget wrapper.
    def render_widget_for(widget_id, opts, &block)
      if widget_id.kind_of?(::Apotomo::Widget)
        widget = widget_id
      else
        widget = root.find_widget(widget_id)
        raise "Couldn't render non-existent widget `#{widget_id}`" unless widget
      end
      
      
      ### TODO: pass options in invoke.
      widget.opts = opts unless opts.empty?
      
      widget.invoke(&block)
    end
    
    # Computes the address hash for a +:source+ widget and an event +:type+.
    # Additional parameters will be merged.
    def address_for(options)
      raise "You forgot to provide :source or :type" unless options.has_key?(:source) and options.has_key?(:type)
      options
    end
  end
end
