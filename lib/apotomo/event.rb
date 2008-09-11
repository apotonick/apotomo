module Apotomo
  # Currently, there is only one Event class which only differs in <tt>type</tt>.
  # An Events default <tt>type</tt> is <tt>:invoke</tt>.
  class Event
    attr_accessor :type, :source_id, :data
    
    def initialize(type=nil, source_id=nil, data={})
      @type       = type
      @source_id  = source_id
      @data       = data
    end
    
    # Return the event type, which is <em>always</em> a Symbol.
    def type
      (@type || :invoke).to_sym
    end
  end
end
