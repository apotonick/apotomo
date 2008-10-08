module Apotomo
  # Provides shortcut methods for creating the widget tree.
  # The mixin target class must have a #controller method.
  module WidgetShortcuts
    def widget(class_name, states, id, *args)
      class_name.to_s.classify.constantize.new(controller, id, states, *args)
    end
    
    def section(id, *args)
      widget('apotomo/section_widget', :widget_content, id, *args)
    end
    
    def cell(base_name, states, id, *args)
      widget(base_name.to_s + '_cell', states, id, *args)
    end
    
    def switch(id, *args)
      widget('apotomo/child_switch_widget', :switch, id, *args)
    end
    
    def tab_panel(id, *args)
      widget('apotomo/tab_panel_widget', :switch, id, *args)
    end
    
    def tab(id, *args)
      widget('apotomo/tab_widget', :widget_content, id, *args)
    end
    
    def domain(id, *args)
      widget('apotomo/domain_widget', :widget_content, id, *args)
    end
  end
end
