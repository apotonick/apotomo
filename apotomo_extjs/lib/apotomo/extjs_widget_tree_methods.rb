module Apotomo
  
  module ExtjsWidgetTreeMethods
    
    def ext_panel(id, extjs_opts={})
      widget('extjs/panel', id, :render_as_function, {}, extjs_opts)
    end
    
    def ext_tree_panel(id, extjs_opts={})
      widget('extjs/tree_panel', id, :render_as_function, {}, extjs_opts)
    end
    
    def ext_tab_panel(id, extjs_opts={})
      widget('extjs/tab_panel', id, :render_as_function, {}, extjs_opts)
    end
    
    def ext_tab(id, extjs_opts={})
      widget('extjs/tab', id, :render_as_function, {}, extjs_opts)
    end
    
  end

end
