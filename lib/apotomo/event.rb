module Apotomo
  # Events are created by Apotomo in #fire. They bubble up from their source to root and trigger
  # event handlers. 
  class Event
    attr_accessor :type, :source, :data
    
    def initialize(type, source=nil, data={})
      @type       = type
      @source     = source
      @data       = data
    end
    
    def _dump(depth)
      raise "You're trying to serialize an instance of Apotomo::Event. Don't do that."
    end
  end
end
