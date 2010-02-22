module Apotomo
  # EventHandlers are "callbacks", not knowing why they exist, but what to do.
  class EventHandler
    
    def process_event(event)
      # do something, and return content.
      nil
    end
    
    def ==(other)
      self.to_s == other.to_s
    end
    
    def call(*args)
      process_event(*args)
    end
    
  end
end
