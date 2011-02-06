module Apotomo
  class RequestProcessor
    attr_reader :session, :root
    
    def initialize(controller, session, options={}, has_widgets_blocks=[])
      @session              = session
      @widgets_flushed      = false
      
      @root = Widget.new(controller, 'root', :display)
      
      attach_stateless_blocks_for(has_widgets_blocks, @root, controller)
      
      if options[:flush_widgets].blank? and ::Apotomo::StatefulWidget.frozen_widget_in?(session)  
        @root = ::Apotomo::StatefulWidget.thaw_for(controller, session, @root)
      else
        #@root = flushed_root
        
        flushed_root  ### FIXME: set internal mode to flushed 
      end
    end
    
    def attach_stateless_blocks_for(blocks, root, controller)
      blocks.each { |blk| controller.instance_exec(root, &blk) }
    end
    
    def flushed_root
      StatefulWidget.flush_storage(session)
      @widgets_flushed = true
      #widget('apotomo/widget', 'root')
    end
        
    def widgets_flushed?;  @widgets_flushed; end
    
    # Fires the request event in the widget tree and collects the rendered page updates.
    def process_for(request_params)
      source = self.root.find_widget(request_params[:source]) or raise "Source #{request_params[:source].inspect} non-existent."
      
      source.fire(request_params[:type].to_sym, request_params) # set data to params for now.
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
    
    # Renders the widget named <tt>widget_id</tt>, passing optional <tt>options</tt> and a block to it.
    # Use this in your #render_widget wrapper.
    def render_widget_for(widget_id, *args, &block) # DISCUSS: allow passing a state here?
      if widget_id.kind_of?(Widget)
        widget = widget_id
      else
        widget = root.find_widget(widget_id)
        raise "Couldn't render non-existent widget `#{widget_id}`" unless widget
      end
      
      widget.invoke(nil, *args, &block)
    end
    
    # Computes the address hash for a +:source+ widget and an event +:type+.
    # Additional parameters will be merged.
    def address_for(options)
      raise "You forgot to provide :source or :type" unless options.has_key?(:source) and options.has_key?(:type)
      options
    end
  end
end
