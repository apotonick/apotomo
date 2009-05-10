#require 'singleton'

module Apotomo
  # Implements a pipeline for EventHandlers to be executed.
  # Discussion is needed here.
  # - should an EventHandler be executed right in time when it is queued?
  #   or should we rather wait until the current rendering cycle finishes?
  #   or introduce a method to stop rendering right after firing in the state method?
  # - should we delete contents that are <= newer contents? they are outdated, though.
  # - should we stop an invoke cycle if a new event is fired which has an EventHandler
  #   that is >= the firing widget. After more thinking, i came to the conclusion this is
  #   too complicated and should put the user's responsibility.
  
  # see acts_as_widget.txt for discussion of the queue pattern.
  
  
  class EventProcessor
    include Singleton
    attr_accessor :queue, :already_processed, :processed_handlers
    
    def initialize
      init!
    end
    
    def init!
      @processed_handlers = []  ### TODO: call this PageUpdateQueue [source => content]
      @queue = []
      self
    end
    
    def processed; processed_handlers;end
    
    def process_handler_for_event(handler, event)
      puts "processing EVENT HANDLER: #{handler}"
      
      content = handler.process_event(event)
      
      processed_handlers << [handler, content]
    end
    
    def queue_handler_with_event(handler, event)
      puts "queueing... #{event.type}: #{handler.to_s}"
      self.queue << [handler, event]
    end
    
    
    def queue_handlers_with_event(handlers, event)
      handlers.each do |h| queue_handler_with_event(h, event) end
    end
    
    
    ### DISCUSS: merge with #process_handlers_for ?
    def process_queue
      process_handlers_for(self.queue)
      return processed_handlers
    end
    
    def process_handlers_for(queue)
      queue.each do |action|
        (handler, event) = action.first, action.last
        
        ### DISCUSS: do we need to provide handler loop protection?
        #next if processed_handlers.include?(handler)
        
        process_handler_for_event(handler, event)
      end
    end
  end

end
