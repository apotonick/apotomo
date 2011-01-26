module Apotomo
  class InvokeEventHandler < EventHandler
    attr_accessor :widget_id, :state
    
    def initialize(options={})
      @widget_id  = options.delete(:widget_id)
      @state      = options.delete(:state)
    end
    
    def process_event(event)
      target = event.source.root.find_by_path(widget_id) ### DISCUSS: widget_id or widget_selector?
      
      target.invoke(state, event)
    end
    
    def to_s; "InvokeEventHandler:#{widget_id}##{state}"; end
  end
end
