module Apotomo
  # encapsulates the "global" widget tree as singleton, thawing/freezing/controller-reconnecting/...
  # implements the automatic root widget creation.
  
  class WidgetTree
    
    include Apotomo::EventAware
    include WidgetShortcuts
    
    attr_reader :controller
    attr_reader :root
    
    def reconnect(controller)
      @controller = controller   # set controller first, then create widgets from AppTree!
      ### TODO/DISCUSS: set @controller in root widget?
      self
    end
    
    def init!
      @root       = widget('apotomo/stateful_widget', :widget_content, '__root__')
      draw(root)
      self
    end
    
    # merge the ApplicationWidgetTree in this tree (useful for testing your app tree in 
    # unit tests).
    def include_application_widget_tree!
      ::ApplicationWidgetTree.new.reconnect(controller).draw(root)
    end
    
    def draw(root)
    end

    # may be overwritten.
    ### DISCUSS: do we need that? or rather put it into another method?
    def self.draw
      yield @root
    end
    
  end
end
