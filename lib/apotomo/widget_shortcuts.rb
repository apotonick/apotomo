module Apotomo
  # Provides shortcut methods for creating the widget tree.
  module WidgetShortcuts
    def widget(class_name, states, id, *args)
      class_name.to_s.classify.constantize.new(id, states, *args)
    end
    
    def section(id, *args)
      widget('apotomo/section_widget', :widget_content, id, *args)
    end
    
    def cell(base_name, states, id, *args)
      widget(base_name.to_s + '_cell', states, id, *args)
    end
    
    def tab_panel(id, *args)
      widget('apotomo/tab_panel_widget', :display, id, *args)
    end
    
    def tab(id, *args)
      widget('apotomo/tab_widget', :display, id, *args)
    end
  end
end
