module Apotomo
  # Introduces event-processing functions into the StatefulWidget.
  module EventMethods
    attr_accessor :evt_processor
    
    
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
      options[:once] = true if options[:once].nil?
      
      handler_opts              = {}
      handler_opts[:widget_id]  = options[:on] || self.name
      handler_opts[:state]      = options[:with]
      
      handler = InvokeEventHandler.new(handler_opts)
      
      return if options[:once] and event_table.all_handlers_for(event_type, options[:from]).include?(handler)
      
      on(event_type, :do => handler, :from => options[:from])
    end
    
    def trigger(*args)
      fire(*args)
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
