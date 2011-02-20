module Apotomo
  class RequestProcessor
    include Hooks
    
    define_hook :after_initialize
    define_hook :after_fire
    
    attr_reader :root
    
    
    def initialize(controller, options={}, has_widgets_blocks=[])
      @root = Widget.new(controller, 'root', :display)
      
      attach_stateless_blocks_for(has_widgets_blocks, @root, controller)
      
      run_hook :after_initialize, self
    end
    
    def attach_stateless_blocks_for(blocks, root, controller)
      blocks.each { |blk| controller.instance_exec(root, &blk) }
    end
    
    # Called when the browser wants an url_for_event address. This fires the request event in 
    # the widget tree and collects the rendered page updates.
    def process_for(request_params)
      source = self.root.find_widget(request_params[:source]) or raise "Source #{request_params[:source].inspect} non-existent."
      
      source.fire(request_params[:type].to_sym, request_params) # set data to params for now.
      
      run_hook :after_fire, self
      source.root.page_updates ### DISCUSS: that's another dependency.
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
