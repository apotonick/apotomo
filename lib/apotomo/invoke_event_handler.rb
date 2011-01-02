module Apotomo
  class InvokeEventHandler < EventHandler
    attr_accessor :widget_id, :state
    
    def initialize(opts={})
      @widget_id  = opts.delete(:widget_id)
      @state      = opts.delete(:state)
    end
    
    def process_event(event)
      target = event.source.root.find_by_path(widget_id) ### DISCUSS: widget_id or widget_selector?
      
      target.invoke(state, event)
    end
    
    def to_s; "InvokeEventHandler:#{widget_id}##{state}"; end
  end
end
