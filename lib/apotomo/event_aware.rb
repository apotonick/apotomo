module Apotomo
  
  # Introduces event-processing functions into the StatefulWidget.
  module EventAware
    attr_writer :evt_table
    attr_accessor :evt_processor
    
    def evt_table
      @evt_table ||= EventTable.new
    end
    
    
    # Attach a listener to some widget. The listener is an Apotomo::EventHandler
    # instance, something similar to a callback.
    # 
    # The created EventHandler will invoke the state <tt>target_state</tt> on the 
    # widget named <tt>target_id</tt> if the specified <tt>event_type</tt> event bubbles
    # to the widget the listener is attached to.
    #
    # The <tt>observed_id</tt> argument acts as filter for the event source. The 
    # EventHandler is only invoked if the event source matches the <tt>observed_id</tt>
    # widget name.
    # If omitted, the <tt>observed_id</tt> is the widget the listener is attached to.
    # You may pass <tt>nil</tt> as id to create a catch-all listener: the handler will
    # be called regardless to the source of the event.
    #
    # Example:
    #   
    #   some_widget << cell(:processor, [:wait, :process_click], 'observer')
    #   some_widget.watch(:click, 'observer', :process_click)
    #   
    # This will invoke the state <tt>:process_click</tt> on the widget named
    # <tt>observer</tt> (which is a child of <tt>some_widget</tt>) if and only if
    # <tt>some_widget</tt> triggers a <tt>click</tt> event.
    #   
    #   user_form = cell(:form, :gui, 'my_form')
    #     user_form << cell(:form, :text_field, 'username')
    #     user_form << cell(:form, :text_field, 'email')
    #     user_form.watch(:change, 'my_form', :_process_events, nil)
    #
    # The EventHandler will be called either if the <tt>username</tt> or the 
    # <tt>email</tt> widget trigger a <tt>change</tt> event, and will invoke the state
    # <tt>:_process_events</tt> on the widget named <tt>my_form</tt>.
    
    def watch(event_type, target_id, target_state, observed_id=self.name)      
      evt_table.monitor(event_type, observed_id, target_id, target_state)
    end
    
    #--
    ### DISCUSS: introduce #watch_any/#watch_all ?
    #--
    
    # Shortcut method for creating an Event with the respective type and 
    # <tt>source_id</tt> and firing it, so it bubbles up from the triggering widget to
    # the root widget.
    # 
    # Example:
    #   trigger(:click, 'username')
    
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
        ###   should be added by #link_to_event or #form_to_event.
        if event.type == :invoke
          ### FIXME: state should be passed in event.
          ###   this is a security hole.
          watch(:invoke, event.source_id, event.data[:state])
        end
      end
      
      puts "looking up callback for #{event.type}: #{event.source_id} [#{name}]"
      local_handlers = evt_table.event_handlers_for(event.type, event.source_id)
      
      
      ### DISCUSS: instantly process handlers (pass event to them)
      ###   if target >= source stop rendering and handle event, forget the former content
      ###   EventHandler can evt.skip (keep going) or evt.stop ?
      local_handlers.each { |h| h.event = event}
      
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
    
    
    def invoke_for_event(evt)
      processor = Apotomo::EventProcessor.instance
      processor.init
      
      fire(evt) # this stores the content in the EventProcessor, which is semi-clean.
      
      return processor.process_queue_for(root, evt)
    end
    
  end

end
