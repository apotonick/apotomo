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
    
    def add_handler_once(handler, opts)
      event_type  = opts[:event_type]
      observed    = opts[:observed] || nil
      
      return if handlers_for_type(event_type).include?(handler)
      
      add_handler_for(handler, event_type, observed)
    end
    
    ### DISCUSS/TODO: mixin in test_helper, since it is needed nowhere else.
    def size
      source2evt.inject(0)do |memo, evts| 
        memo + evts[1].inject(0) {|sum, h| sum + h[1].size} # h => [key, value].
      end || 0
    end
    
    # Attach an event handler which invokes a widget state.
    ### DISCUSS: rename to "watch-and-respond-to-with-invoke".
    def monitor(evt_type, observed_widget_id, target_id, target_state)
      ### TODO: deprecate #monitor.
      handler = InvokeEventHandler.new(:widget_id => target_id, :state => target_state)
      
      add_handler_for(handler, evt_type, observed_widget_id)
    end
    
    
    # Get EventHandlers for the specified +evt_type+ and the source widget +source_id+.
    # Note that sourceless handlers for +evt_type+ are returned, too.
    def event_handlers_for(evt_type, source_id)
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
