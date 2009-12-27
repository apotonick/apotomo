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
        child_id  = value_for_path(param(:deep_link))
      else
        child_id  = param(param_name)
      end
      
      find_child(child_id) || find_child(@current_child_id) || default_child
    end
    
    def default_child;  children.first;   end
    def param_name;     name;             end
    
    
    def find_child(id)
      children.find { |c| c.name.to_s == id }
    end
    
    
    def recognizes_path?(path)
      value = value_for_path(path)
      return unless value
      
      return value != @current_child_id
    end
    
    # Tries to find a corresponding directory in the url fragment
    # and returns the value.
    def value_for_path(path)
      return if path.blank?
      
      if path_portion = path.split("/").find {|i| i.include?(name)}
        return path_portion.sub("#{param_name}=", "")
      end
    end
    
    
    
    def address(way={}, target=self, state=nil)
      way.merge!( local_address(target, way, state) )

      return way if isRoot?

      return parent.address(way, target)
    end

      
    # Override this if the widget needs to set state recovery information for a 
    # bookmarkable link.
    # Must return a Hash with the local state recovery information.
    def local_fragment
      "#{name}=#{current_child_id}"
    end
    
    
    def url_fragment_for_tab(tab)
      url_fragment_with("#{param_name}=#{tab.name}")
    end
  end
end
