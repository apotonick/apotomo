module Apotomo
  class InvokeEventHandler < EventHandler
    attr_accessor :widget_id, :state
    
    
    def process_event(event)
      target = event.source.root.find_by_path(widget_id) ### DISCUSS: widget_id or widget_selector?
      
      puts "EventHandler: invoking #{target.name}##{state}"
      ### DISCUSS: let target access event?
      ###   pass additional opts to #invoke?
      ### DISCUSS: pass block here?
      target.opts[:event] = event
      @content = target.invoke(state)
      
      self
    end
    
    def to_s; "InvokeEventHandler:#{widget_id}##{state}"; end
  end
end
