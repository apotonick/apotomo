module Apotomo
  class TabPanelWidget < StatefulWidget
    transition :from => :display, :to => :switch
    transition                    :in => :switch
    
    attr_accessor :current_child_id
    
    
    # Called in StatefulWidget's constructor.
    def initialize_deep_link_for(id, start_states, opts)
      return unless opts[:is_url_listener]
      
      respond_to_event :urlChange, :from => self.name, :with => :switch
    end
    
    
    
    def display
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
      if responds_to_url_change?
        child_id  = url_fragment[param_name]
      else
        child_id  = param(param_name)
      end
      
      find_child(child_id) || find_child(@current_child_id) || default_child
    end
    
    def default_child;  children.first;   end
    
    
    def find_child(id)
      children.find { |c| c.name.to_s == id }
    end
    
    def param_name; name; end
    
    
    # Called by deep_link_widget#process to query if we're involved in an URL change.
    def responds_to_url_change_for?(fragment)
      # don't respond to an empty/invalid/ fragment as we don't get any information from it:
      return if fragment[param_name].blank?
      
      fragment[param_name] != @current_child_id
    end
    
    def local_fragment
      "#{param_name}=#{current_child_id}"
    end
    
    
    # Used in view to create the tab link in deep-linking mode.
    def url_fragment_for_tab(tab)
      url_fragment_for("#{param_name}=#{tab.name}")
    end
    
    
    def address(way={}, target=self, state=nil)
      way.merge!( local_address(target, way, state) )

      return way if isRoot?

      return parent.address(way, target)
    end
  end
end
