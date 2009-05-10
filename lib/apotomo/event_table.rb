module Apotomo
  
  class EventTable
    attr_accessor :source2evt
    
    def initialize
      @source2evt = {}
    end
    
    def add_handler(handler, opts)
      event_type  = opts[:event_type]
      source_id   = opts[:source_id] || nil
      
      handlers_for(event_type, source_id) << handler
    end
    
    def add_handler_once(handler, opts)
      return if handlers_for(opts[:event_type], opts[:source_id]).include?(handler)
      
      add_handler(handler, opts)
    end
    
    def handlers_for(event_type, source_id=nil)
      evt_types = source2evt[source_id] ||= {}
      evt_types[event_type] ||= []
    end
    
    # Returns all handlers, even the catch-all.
    def all_handlers_for(event_type, source_id)
      handlers_for(event_type, source_id) + handlers_for(event_type, nil)
    end
        
    ### DISCUSS/TODO: mixin in test_helper, since it is needed nowhere else.
    def size
      source2evt.inject(0)do |memo, evts| 
        memo + evts[1].inject(0) {|sum, h| sum + h[1].size} # h => [key, value].
      end || 0
    end
  end
end
