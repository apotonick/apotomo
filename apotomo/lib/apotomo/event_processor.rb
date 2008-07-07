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
    def process_handlers_for(handlers, tree, page)
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
    
    def process_handler_for(handler, tree, page)
      return if already_processed[handler.widget_id.to_s + "-" + handler.state.to_s]
      puts "processing PAGE handler: "+handler.widget_id.to_s + "-" + handler.state.to_s
      #puts already_processed.inspect
      #begin
        processed = handler.process_for(tree, page)
      #rescue => e
        #begin
        #  #require 'pp'
        #  #pp e
        #rescue Exception => e2
        #  p e2.class
        #end
        #puts "Scheisse"
        #exit
        #p e
      #end  
      
      already_processed[handler.widget_id.to_s + "-" + handler.state.to_s] = true
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
      process_handlers_for_tree(self.queue, tree)
      return processed_handlers
    end
    
    def process_queue_for(tree, page)
      process_handlers_for(self.queue, tree, page)
      return processed_handlers
    end
  end

end
