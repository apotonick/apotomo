module Apotomo
  
  class EventTable
    attr_accessor :source2evt
    
    def initialize
      @source2evt = {}
    end
    
    def add_handler_for(handler, evt_type, observed_id=nil)
      evt_types = source2evt[observed_id] || {}
      type_handlers = evt_types[evt_type] || []
      type_handlers << handler
      evt_types[evt_type] = type_handlers
      source2evt[observed_id] = evt_types
    end
    
    def monitor(evt_type, observed_widget_id, target_widget_id, target_state)
      handler = EventHandler.new
      handler.widget_id = target_widget_id
      handler.state     = target_state
      
      add_handler_for(handler, evt_type, observed_widget_id)
    end
    
    
    # Get EventHandlers for the specified +evt_type+ and the source widget +source_id+.
    # Note that sourceless handlers for +evt_type+ are returned, too.
    def event_handlers_for(evt_type, source_id)
      raise "no source_id given for #event_handlers_for!" unless source_id
      
      ### DISCUSS: handlers with explicit source first.
      handlers_for_type_and_source(evt_type, source_id) + handlers_for_type(evt_type)
    end
    
    def handlers_for_type_and_source(evt_type, source_id)
      handlers = []
      if (types = source2evt[source_id])
        handlers = types[evt_type] || []
      end
      handlers
    end
    
    def handlers_for_type(evt_type)
      handlers_for_type_and_source(evt_type, nil)
    end
    
  end
end
