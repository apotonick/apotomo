module Apotomo
  
  class WidgetTree
    
    attr_accessor :controller
    attr_reader :root
    
    
    def initialize(controller)
      @controller = controller      
      @root       = widget('apotomo/stateful_widget', 'root')
    end
    
    
    def draw_tree
      draw(@root)
      return @root
    end


    # may be overwritten.
    ### DISCUSS: do we need that? or rather put it into another method?
    def draw(root)
    end
    
    
    
    
    # widgets -------------------------------------------------------------------
    
    def widget(class_name, id, *args)
      class_name.to_s.classify.constantize.new(controller, id, *args)
    end
    
    def section(id, *args)
      widget('apotomo/section_widget', id, :widget_content, *args)
    end
    
    def cell(base_name, states, id, *args)
      widget(base_name.to_s + '_cell', id, states, *args)
    end
    
    def switch(id, *args)
      widget('apotomo/child_switch_widget', id, :switch, *args)
    end
    
    def tab_panel(id, *args)
      widget('apotomo/tab_panel_widget', id, :switch, *args)
    end
    
    def tab(id, *args)
      widget('apotomo/tab_widget', id, :widget_content, *args)
    end
    
  end
end
