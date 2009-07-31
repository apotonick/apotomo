module Apotomo
  
  # Introduces event-processing functions into the StatefulWidget.
  module EventMethods
    attr_writer :evt_table
    attr_accessor :evt_processor
    
    def evt_table
      @evt_table ||= EventTable.new
    end
    
    
    # Instructs the widget to look out for <tt>event_type</tt> Events that are passing by while bubbling.
    # If an appropriate event is encountered the widget will send the targeted widget (or itself) to another
    # state, which implies an update of the invoked widget.
    #
    # You may configure the event handler with the following <tt>options</tt>:
    #  :with  => (required) the state to invoke on the target widget
    #  :on    => (optional) the targeted widget's id, defaults to <tt>self.name</tt>
    #  :from  => (optional) the source id of the widget that triggered the event, defaults to any widget
    #
    # Example:
    #   
    #   trap = cell(:input_field, :smell_like_cheese, 'mouse_trap')
    #   trap.respond_to_event :mouseOver, :with => :catch_mouse
    #
    # This would instruct <tt>trap</tt> to catch a <tt>:mouseOver</tt> event from any widget (including itself) and
    # to invoke the state <tt>:catch_mouse</tt> on itself as trigger.
    #
    #   
    #   hunter = cell(:form, :hunt_for_mice, 'my_form')
    #     hunter << cell(:input_field, :smell_like_cheese,  'mouse_trap')
    #     hunter << cell(:text_area,   :stick_like_honey,   'bear_trap')
    #   hunter.respond_to_event :captured, :from => 'mouse_trap', :with => :refill_cheese, :on => 'mouse_trap'
    #
    # As both the bear- and the mouse trap can trigger a <tt>:captured</tt> event the later <tt>respond_to_event</tt>
    # would invoke <tt>:refill_cheese</tt> on the <tt>mouse_trap</tt> widget as soon as this and only this widget fired.
    # It is important to understand the <tt>:from</tt> parameter as it filters the event source - it wouldn't make
    # sense to refill the mouse trap if the bear trap snapped, would it?
    
    def respond_to_event(event_type, options)
      handler_opts  = {}
      table_opts    = {}
      
      # assuming we're creating InvokeEventHandlers only:
      handler_opts[:widget_id]  = options[:on]    || self.name
      handler_opts[:state]      = options.fetch(:with)
      
      table_opts[:event_type]   = event_type
      table_opts[:source_id]    = options[:from]
      
      handler = InvokeEventHandler.new(handler_opts)
      
      if options[:again]
        evt_table.add_handler(handler, table_opts)
        return
      end
      
      evt_table.add_handler_once(handler, table_opts)
    end
    
    ### TODO: deprecate.
    def watch(event_type, target_id, target_state, source_id=self.name)
      handler = InvokeEventHandler.new(:widget_id => target_id, :state => target_state) 
      evt_table.add_handler(handler, :event_type => event_type, :source_id => source_id)
    end
    
    
    # Same as #watch, but checks if the identical EventHandler has already been set.
    # If so, attaching is omitted. This prevents <em>multiple identical</em> 
    # EventHandlers for the same Event.
    
    ### TODO: deprecate.
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
