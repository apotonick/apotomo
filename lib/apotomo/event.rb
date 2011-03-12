module Apotomo
  # Events are created by Apotomo in #fire. They bubble up from their source to root and trigger
  # event handlers. 
  class Event < Onfire::Event
    def to_s
      "<Event :#{type} source=#{source.widget_id}>"
    end
    
    delegate :[], :to => :data
  end
end
