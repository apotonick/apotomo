module Apotomo
  
  class WidgetTree
    
    include WidgetShortcuts
    
    attr_accessor :controller
    attr_reader :root
    
    
    def initialize(controller)
      @controller = controller      
      @root       = widget('apotomo/stateful_widget', :widget_content, 'root')
    end
    
    
    def draw_tree
      draw(@root)
      return @root
    end


    # may be overwritten.
    ### DISCUSS: do we need that? or rather put it into another method?
    def draw(root)
    end
    
  end
end
