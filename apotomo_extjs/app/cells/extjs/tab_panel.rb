module Extjs
  class TabPanel < Panel
    
    def extjs_class; "Ext.TabPanel"; end
    
    def init_config
      @config = {
        :id         => name,
      }
    end
    
    
    def transition_map
      { :render_as_function => [:load],
        :load => [:load]
      }
    end
  end
end
