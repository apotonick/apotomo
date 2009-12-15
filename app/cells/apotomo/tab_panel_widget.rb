module Apotomo
  class TabPanelWidget < StatefulWidget
    
    transition :from => :display, :to => :switch
    transition                    :in => :switch
    
    def display
      @current_child_id  = default_child.name
      
      
      @tabs=[]
      
      for tab in children
        @tabs << [tab.title, local_address(tab, nil, nil), tab.name]
      end

      set_current_child
      
      respond_to_event(:switchChild, :with => :switch)
      
      render
    end
    
    
    def switch
      @current_child_id  = find_current_child.name
      
      set_current_child
      
      render :view => :display
    end
    
    
    def set_current_child
      current_child = find_child_for_id(@current_child_id)
      @current_child_title = current_child.title
    end
    
    def children_to_render
      [children.find{ |c| c.name == @current_child_id } ]
    end
    
    def find_current_child
      child_id = param(param_name_for_current_child)
      find_child_for_id(child_id) || find_child_for_id(@current_child_id) || default_child
    end
    
    def default_child;      children.first;   end
    
    def param_name_for_current_child
      self.name.to_s + "_child"
    end
    
    
    def find_child_for_id(id)
      children.find { |c| c.name.to_s == id }
    end
    
  end
end
