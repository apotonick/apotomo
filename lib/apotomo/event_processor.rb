require 'singleton'

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
  class EventProcessor
    include Singleton
    attr_accessor :queue, :already_processed, :processed_handlers
    
    #def initialize(evt_table, controller)
    def initialize
      #@evt_table = evt_table
      #@controller = controller
      init
    end
    
    def init
      @processed_handlers = []
      @already_processed = {}
      @queue = []
    end
    
    
    def process_handlers_for(handlers, tree, page=nil)
      #puts already_processed.inspect
      handlers.each do |handler|
        #puts handler.inspect
        #puts
        #next if already_processed[handler.widget_id.to_s + "-" + handler.state.to_s]
        process_handler_for(handler, tree, page)
      end
      
      #puts "queue:"
      #puts handlers.inspect
      #  puts
    end
    
    
    def process_handler_for(handler, tree, page=nil)
      return if already_processed[handler.widget_id.to_s + "-" + handler.state.to_s]
      puts "processing PAGE handler: #{handler.widget_id}-#{handler.state}"
      
      processed = handler.process_for(tree, page)
      
      already_processed["#{handler.widget_id}-#{handler.state}"] = true
      processed_handlers << processed
    end
    
    
    
    def queue_handler(handler)
      puts "queueing... #{handler.inspect}"
      self.queue << handler
    end
    def queue_handlers(handlers)
      handlers.each {|h| queue_handler(h)}
    end
    
    
    ### DISCUSS: right now, page is not used since widgets shouldn't fiddle around with
    ###   RJS.
    def process_queue_for(tree, page=nil)
      process_handlers_for(self.queue, tree, page)
      return processed_handlers
    end
  end

end
