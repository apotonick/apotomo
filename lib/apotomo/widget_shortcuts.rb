module Apotomo
  # Provides shortcut methods for creating the widget tree.
  # The mixin target class must have a #controller method.
  module WidgetShortcuts
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
    
    def domain(id, *args)
      widget('apotomo/domain_widget', id, :widget_content, *args)
    end
  end
end
