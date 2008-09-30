module Apotomo
  class TabPanelWidget < ChildSwitchWidget
    
    def switch
      super
      
      @tabs=[]
      
      for tab in children
        @tabs << [tab.title, local_address(tab, nil, nil), tab.name]
      end

      set_current_child
      
      peek(:switchChild, name, :_switch)
      
      nil
    end
    
    
    def _switch
      super
      set_current_child # sets #state_view to :switch.
      
      nil
    end
    
    
    def set_current_child
      current_child = find_child_for_id(@current_child_id)
      @current_child_title = current_child.title
    end
    
  end
end
