require 'apotomo/invoke_event_handler'

module Apotomo
  # Event-related methods and onfire bridge for Widget.
  module EventMethods
    extend ActiveSupport::Concern
    
    included do
      after_initialize :add_class_event_handlers
      
      inheritable_attr :responds_to_event_options
      self.responds_to_event_options = []
    end
    
    
    attr_writer :page_updates
    
    def page_updates
      @page_updates ||= []
    end
    
    
    module ClassMethods
      # Instructs the widget to look out for +type+ events. If an appropriate event starts from or passes the widget, 
      # the defined trigger state is executed.
      #
      #   class MouseWidget < Apotomo::Widget
      #     responds_to_event :squeak
      #
      #     def squeak(evt)
      #       update
      #     end
      #
      # Calls #squeak when a <tt>:squeak</tt> event is encountered.
      # 
      # == Options
      # Any option except the event +type+ is optional.
      #
      # [<tt>:with => state</tt>] 
      #   executes +state+, defaults to +type+.
      #     responds_to_event :squeak, :with => :chirp
      #   will invoke the +#chirp+ state method.
      # [<tt>:on => id</tt>] 
      #   execute the trigger state on another widget.
      #     responds_to_event :squeak, :on => :cat
      #   will invoke the +#squeak+ state on the +:cat+ widget.
      # [<tt>:from => id</tt>] 
      #   executes the state <em>only</em> if the event origins from +id+.
      #     responds_to_event :squeak, :from => :kid
      #   will invoke the +#squeak+ state if +:kid+ triggered <em>and</em> if +:kid+ is a decendent of the current widget.
      # [<tt>:passing => id</tt>] 
      #   attaches the observer to another widget. Useful if you want to catch bubbling events in +root+.
      #     responds_to_event :squeak, :passing => :root
      #   will invoke the state on the current widget if the event passes +:root+ (which is highly probable).
      #
      # == Inheritance
      # Note that the observers are inherited. This allows deriving a widget class without having to redefine the
      # responds_to_event blocks.
      def responds_to_event(*options)
        # DISCUSS: this is a Hooks.declarative_attr candidate, too.
        return set_global_event_handler(*options) if options.dup.extract_options![:passing]
        
        responds_to_event_options << options
      end
      
    private
      # Adds an event handler to a non-local widget. Called in #responds_to_event when the 
      # :passing option is set.
      #
      # This usually leads to something like 
      #   root.respond_to_event :click, :on => 'jerry'
      def set_global_event_handler(type, options)
        after_add do
          opts = options.reverse_merge(:on => widget_id)
          root.find_widget(opts.delete(:passing)).respond_to_event(type, opts)
        end
      end
    end
    
    # Same as #responds_to_event but executed on the widget instance, only.
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
    
    # Actually executes the #responds_to_event calls from the class on the instance.
    def add_class_event_handlers(*)
      self.class.responds_to_event_options.each { |options| respond_to_event(*options) }
    end
  end
end
