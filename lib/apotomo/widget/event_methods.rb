require 'apotomo/invoke_event_handler'

module Apotomo
  # Introduces event-processing functions into the StatefulWidget.
  module EventMethods
    extend ActiveSupport::Concern
    
    included do
      after_initialize :add_class_event_handlers
    end
    
    attr_writer :page_updates
    
    def page_updates
      @page_updates ||= []
    end
    
    def add_class_event_handlers(*)
      self.class.responds_to_event_options.each { |options| respond_to_event(*options) }
    end
    
    module ClassMethods
      # :passing
      def responds_to_event(*options)
        return set_global_event_handler(*options) if options.dup.extract_options![:passing]
        
        responds_to_event_options << options
      end
      alias_method :respond_to_event, :responds_to_event
    
      def responds_to_event_options
        @responds_to_event_options ||= []
      end
      
    private
      # Adds an event handler to a non-local widget. Called in #responds_to_event when the 
      # :passing option is set.
      #
      # This usually leads to something like 
      #   root.respond_to_event :click, :on => 'jerry'
      def set_global_event_handler(type, options)
        after_add do
          options = options.reverse_merge(:on => self.widget_id)
          root.find_widget(options.delete(:passing)).respond_to_event(type, options)
        end
      end
    end
    # Instructs the widget to look out for <tt>type</tt> Events that are passing by while bubbling.
    # If an appropriate event is encountered the widget will send the targeted widget (or itself) to another
    # state, which implies an update of the invoked widget.
    #
    # You may configure the event handler with the following <tt>options</tt>:
    #  :with  => (optional) the state to invoke on the target widget, defaults to +type+.
    #  :on    => (optional) the targeted widget's id, defaults to <tt>self.name</tt>
    #  :from  => (optional) the source id of the widget that triggered the event, defaults to any widget
    #
    # Example:
    #   
    #   trap = widget(:trap, :charged, 'mouse_trap')
    #   trap.respond_to_event :mouseOver, :with => :catch_mouse
    #
    # This would instruct +trap+ to catch a <tt>:mouseOver</tt> event from any widget (including itself) and
    # to invoke the state <tt>:catch_mouse</tt> on itself as trigger.
    #
    #   
    #   hunter = widget(:form, :hunt_for_mice, 'my_form')
    #     hunter << widget(:input_field, :smell_like_cheese,  'mouse_trap')
    #     hunter << widget(:text_area,   :stick_like_honey,   'bear_trap')
    #   hunter.respond_to_event :captured, :from => 'mouse_trap', :with => :refill_cheese, :on => 'mouse_trap'
    #
    # As both the bear- and the mouse trap can trigger a <tt>:captured</tt> event the later <tt>respond_to_event</tt>
    # would invoke <tt>:refill_cheese</tt> on the <tt>mouse_trap</tt> widget as soon as this and only this widget fired.
    # It is important to understand the <tt>:from</tt> parameter as it filters the event source - it wouldn't make
    # sense to refill the mouse trap if the bear trap snapped, would it? 
    def respond_to_event(type, options={})
      options = options.reverse_merge(:once => true,
                                      :with => type,
                                      :on   => self.name)
      
      handler = InvokeEventHandler.new(:widget_id => options[:on], :state => options[:with])
      
      return if options[:once] and event_table.all_handlers_for(type, options[:from]).include?(handler)
      
      on(type, :call => handler, :from => options[:from])
    end
    
    # Fire an event of +type+ and let it bubble up. You may add arbitrary payload data to the event.
    #
    # Example:
    #
    #   trigger(:dropped, :area => 59)
    #
    # which can be queried in a triggered state.
    #
    #   def on_drop(event)
    #     if event[:area] == 59 
    def trigger(*args)
      fire(*args)
    end
    
    # Get all handlers from self for the passed event (overriding Onfire#local_event_handlers).
    def handlers_for_event(event)
      event_table.all_handlers_for(event.type, event.source.name) # we key with widget_id.
    end
    
  protected
    def event_for(*args)  # defined in Onfire: we want Apotomo::Event.
      Event.new(*args)
    end
  end
end
