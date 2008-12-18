module Apotomo
  class EventHandler
    attr_accessor :widget_id, :state, :content, :event
    
    
    def process_for(tree, page)
      target = tree.find_by_path(widget_id) ### DISCUSS: widget_id or widget_selector?
      raise "widget '#{widget_id}' could not be found." unless target
      
      puts "EventHandler: invoking #{target.name}##{state}"
      ### DISCUSS: let target access event?
      ###   pass additional opts to #invoke?
      target.opts[:event] = event
      @content = target.invoke(state)
      
      ### FIXME: this :afterInvoke event is somehow inconsistent, it just notifies about
      ###   _one_ #invoke per handler (although there might be children invoked!).
      target.trigger(:afterInvoke)
      
      self
    end
  end
end
