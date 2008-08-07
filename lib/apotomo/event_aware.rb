module Apotomo
  module EventAware
    attr_writer :evt_table
    attr_accessor :evt_processor
    
    def evt_table
      @evt_table ||= EventTable.new
    end
    
    ### NOTE: observer means "look out for onWidget events!".
    def observe(observed_id, target_id, target_state)
      evt_table.monitor(:onWidget, observed_id, target_id, target_state)
    end
    
    # Attach a listener to some widget. The listener is an Apotomo::EventHandler,
    # instance, something similar to a callback.
    def watch(event_type, target_id, target_state, observed_id=self.name)      
      evt_table.monitor(event_type, observed_id, target_id, target_state)
    end
    
    
    # shortcut method for creating an Event and firing it.
    # 
    # Example: trigger(:click, 'my_tree_widget')
    def trigger(event_type, source_id=self.name)
      puts "triggered #{event_type.inspect} in #{source_id.inspect}"
      
      event = Event.new
      event.type = event_type
      event.source_id = source_id
      
      fire(event)
    end
    
    def fire(event)
      bubble_handlers_for(event)
    end
    
    
    def bubble_handlers_for(event, handlers=[])
      if event.source_id == name
        ### FIXME: let the source widget add this handler:
        ###   should be added by #link_to_widget or #form_to_widget.
        if event.type == :invoke
          ### FIXME: state should be passed in event.
          watch(:invoke, event.source_id, params[:state].to_sym)
        end
      end
      
      puts "looking up callback for #{event.type}: #{event.source_id} [#{name}]"
      local_handlers = evt_table.event_handlers_for(event.type, event.source_id)
      handlers      += local_handlers
      
      #puts local_handlers
      #puts evt_table.source2evt.inspect
      
      ### DISCUSS: we always bubble up, if handlers are found or not.
      ###   should we have a stop-assignment ("veto")?
      if isRoot?
        process_handlers(handlers)
        return
      end
      
      parent.bubble_handlers_for(event, handlers)
    end
    
    
    def process_handlers(handlers)
      Apotomo::EventProcessor.instance.queue_handlers(handlers)
    end
    
  end


  class Event
    attr_accessor :type, :source_id, :data
  end

end
