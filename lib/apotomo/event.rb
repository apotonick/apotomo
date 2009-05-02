module Apotomo
  # Currently, there is only one Event class which only differs in <tt>type</tt>.
  # An events' <tt>type</tt> defaults <tt>:invoke</tt>.
  class Event
    attr_accessor :type, :source, :data
    
    def initialize(type=nil, source=nil, data={})
      @type       = type
      @source     = source
      @data       = data
    end
    def widget_id; raise "wrong! you shouldn't use me like an event handler."; end
    
    # Return the event type, which is <em>always</em> a Symbol.
    def type
      (@type || :invoke).to_sym
    end
    
    
    ### FIXME: who keeps a stale reference to the event?
    def _dump(depth)
      ""
    end
    def self._load(str)
      Event.new
    end
  end
end
