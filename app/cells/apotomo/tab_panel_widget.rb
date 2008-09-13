module Apotomo
  class TabPanelWidget < ChildSwitchWidget
    
    def switch
      super
      
    # create TabNav model according to TabPages:
      #tabnav_class = Class.new(Tabnav::Base)  # this instance will be garbage after this method. (?)
      @tabs=[]
      
      for tab in children
        @tabs << [tab.title, tab.address]
        #tabnav_class.add_tab do
        #  named tab.title
        #  links_to tab.address
        #end
      end

      set_current_child
      #@tabs = tabnav_class.instance.tabs
      
      nil
    end
    
    
    def _switch
      super
      set_current_child
      
      nil
    end
    
    
    def set_current_child
      current_child = find_child_for_id(@current_child_id)
      @current_child_title = current_child.title
    end
    
  end
end
