module Apotomo
  
  class EventTable
    attr_accessor :source2evt
    
    def initialize
      @source2evt = {}
    end
    
    def add_handler_for(handler, evt_type, observed_id)
      evt_types = source2evt[observed_id] || {}
      type_handlers = evt_types[evt_type] || []
      type_handlers << handler
      evt_types[evt_type] = type_handlers
      source2evt[observed_id] = evt_types
    end
    
    def monitor(evt_type, observed_widget_id, target_widget_id, target_state)
      ###@ handler = PageEventHandler.new
      handler = EventHandler.new
      handler.widget_id = target_widget_id
      handler.state     = target_state
      ### DISCUSS: set action here, or put it in EventHandler?
      evt_types = source2evt[observed_widget_id] || {}
      type_handlers = evt_types[evt_type] || []
      type_handlers.push handler
      evt_types[evt_type] = type_handlers
      source2evt[observed_widget_id] = evt_types
      ### TODO: fix the above, as it is done in real software.
    end
    
    def event_handlers_for(evt_type, source_id)
      handlers = []
      if (types = source2evt[source_id])
        handlers = types[evt_type] || []
      end
      
      handlers
    end
  end
  
  
  

  
  
  
    
end
