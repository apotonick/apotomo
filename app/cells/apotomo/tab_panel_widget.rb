module Apotomo
  class TabPanelWidget < StatefulWidget
    transition :from => :display, :to => :switch
    transition                    :in => :switch
    
    attr_accessor :current_child_id
    
    
    def display
      respond_to_event :urlChanged, :from => self.name, :with => :switch
      respond_to_event(:switchChild, :with => :switch)
      
      
      @current_child_id  = find_current_child.name
      
      render :locals => {:tabs => children}
    end
    
    
    def switch
      @current_child_id  = find_current_child.name
      
      render :view => :display, :locals => {:tabs => children}
    end
    
    
    def children_to_render
      [children.find{ |c| c.name == @current_child_id } ]
    end
    
    ### DISCUSS: use #find_param instead of #param to provide a cleaner parameter retrieval?
    def find_current_child
      if adds_deep_link?
        child_id  = local_value_for_path(param(:deep_link))
      else
        child_id  = param(param_name)
      end
      
      find_child(child_id) || find_child(@current_child_id) || default_child
    end
    
    def default_child;  children.first;   end
    
    
    def find_child(id)
      children.find { |c| c.name.to_s == id }
    end
    
    def param_name; local_fragment_key; end
    
    
    def responds_to_local_fragment_value?(value)
      value != @current_child_id
    end
    
  
    
    
    
    def address(way={}, target=self, state=nil)
      way.merge!( local_address(target, way, state) )

      return way if isRoot?

      return parent.address(way, target)
    end
    
    def local_fragment
      "#{local_fragment_key}=#{current_child_id}"
    end
    
    
    # Used in view to create the tab link in deep-linking mode.
    def url_fragment_for_tab(tab)
      url_fragment_with("#{local_fragment_key}=#{tab.name}")
    end
  end
end
