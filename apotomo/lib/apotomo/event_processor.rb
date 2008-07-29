require 'singleton'

module Apotomo
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
    
    
    def process_handlers_for_tree(handlers, tree)
      raise "deprecated"
      #puts already_processed.inspect
      handlers.each do |handler|
        #puts handler.inspect
        #puts
        #next if already_processed[handler.widget_id.to_s + "-" + handler.state.to_s]
        process_handler_for_tree(handler, tree)
      end
      
      #puts "queue:"
      #puts handlers.inspect
      #  puts
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
    
    
    
    def process_handler_for_tree(handler, tree)
      raise "deprecated"
      return if already_processed[handler.widget_id.to_s + "-" + handler.state.to_s]
      puts "processing: "+handler.widget_id.to_s + "-" + handler.state.to_s
      #puts already_processed.inspect
      processed = handler.process_for_tree(tree)
      
      already_processed[handler.widget_id.to_s + "-" + handler.state.to_s] = true
      processed_handlers << processed
      
        ### FIXME!
        ### DISCUSS: put this in the EventHandler?


###@        process_for(:onWidget, handler.widget_id) # "trigger onWidget event".
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
    
    def process_queue_for_tree(tree)
      raise "deprecated"
      process_handlers_for_tree(self.queue, tree)
      return processed_handlers
    end
    
    ### DISCUSS: right now, page is not used since widgets shouldn't fiddle around with
    ###   RJS.
    def process_queue_for(tree, page=nil)
      process_handlers_for(self.queue, tree, page)
      return processed_handlers
    end
  end

end
