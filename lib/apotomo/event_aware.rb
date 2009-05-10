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
    # EventHandler is only invoked if the event source matches the <tt>source_id</tt>
    # widget name.
    # If omitted, the <tt>source_id</tt> is the widget the listener is attached to.
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
    
    def watch(event_type, target_id, target_state, source_id=self.name)
      handler = InvokeEventHandler.new(:widget_id => target_id, :state => target_state) 
      evt_table.add_handler(handler, :event_type => event_type, :source_id => source_id)
    end
    
    
    # Same as #watch, but checks if the identical EventHandler has already been set.
    # If so, attaching is omitted. This prevents <em>multiple identical</em> 
    # EventHandlers for the same Event.
    def peek(event_type, target_id, target_state, source_id=self.name)
      handler = InvokeEventHandler.new(:widget_id => target_id, :state => target_state)
      evt_table.add_handler_once(handler, :event_type => event_type, :source_id => source_id) 
    end
    #--
    ### DISCUSS: introduce #watch_any/#watch_all ?
    #--
    
    # Shortcut method for creating an Event with the respective type and 
    # <tt>source</tt> and firing it, so it bubbles up from the triggering widget to
    # the root widget.
    # 
    # Example:
    #   trigger(:click, 'username')
    
    def trigger(event_type, source_id=self.name)
      puts "triggered #{event_type.inspect} in #{source_id.inspect}"
      
      event         = Event.new
      event.type    = event_type
      event.source  = root.find_by_id(source_id)
      
      fire(event)
    end
    
    def fire(event)
      bubble_handlers_for(event)
    end
    
    
    ### DISCUSS: rename to #bubble_event or #collect_handlers_for_bubbling_event.
    def bubble_handlers_for(event, handlers=[])
      puts "looking up callback for #{event.type}: #{event.source.name} [#{name}]"
      local_handlers = evt_table.all_handlers_for(event.type, event.source.name)
      ### DISCUSS: rename to #event_handlers_for_event(event)?
      
      ### DISCUSS: instantly process handlers (pass event to them)
      ###   if target >= source stop rendering and handle event, forget the former content
      ###   EventHandler can evt.skip (keep going) or evt.stop ?
      
      
      handlers += local_handlers
      ### DISCUSS: we always bubble up, if handlers are found or not.
      ###   should we have a stop-assignment ("veto")?
      if isRoot?
        # when reaching root all handlers watching the bubbling event were collected.
        process_handlers_with_event(handlers, event)
        return
      end
      
      parent.bubble_handlers_for(event, handlers)
    end
    
    
    def process_handlers_with_event(handlers, event)
      Apotomo::EventProcessor.instance.queue_handlers_with_event(handlers, event)
    end
    
    
    # Start the rendering/event cycle by fireing an <tt>event</tt>.
    # Returns the filled, rendered EventHandler pipeline after all handlers have been
    # executed.
    def invoke_for_event(evt)
      processor = Apotomo::EventProcessor.instance.init!
      
      fire(evt)
      
      return processor.process_queue
    end
    
    # Invokes <tt>state</tt> on the widget <em>and</end> updates itself on the page. This should
    # never be called from outside but in setters when some internal value changed and must be
    # displayed instantly.
    # 
    # Implements the following pattern (TODO: remove example as soon as invoke! proofed):
    # 
    #   def title=(str)
    #     @title = str
    #     peek(:update, self.name, :display, self.name)
    #     trigger(:update)
    #   end
    def invoke!(state)
      ### TODO: encapsulate in PageUpdateQueue:
      Apotomo::EventProcessor.instance.processed_handlers << [name, invoke(:state)]
    end
    
  end

end
