module Apotomo
  class InvokeEventHandler < EventHandler
    attr_accessor :widget_id, :state
    
    def initialize(opts={})
      @widget_id  = opts.delete(:widget_id)
      @state      = opts.delete(:state)
    end
    
    def process_event(event)
      target = event.source.root.find_by_path(widget_id) ### DISCUSS: widget_id or widget_selector?
      
      puts "EventHandler: invoking #{target.name}##{state}"
      ### DISCUSS: let target access event?
      ###   pass additional opts to #invoke?
      ### DISCUSS: pass block here?
      target.opts[:event] = event
      
      target.invoke(state)
    end
    
    def to_s; "InvokeEventHandler:#{widget_id}##{state}"; end
  end
end
