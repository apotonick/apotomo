module Apotomo
  # Events are created by Apotomo in #fire. They bubble up from their source to root and trigger
  # event handlers. 
  class Event < Onfire::Event
    def _dump(depth)
      raise "You're trying to serialize an instance of Apotomo::Event. Don't do that."
    end
    
    delegate :[], :to => :data
  end
end
