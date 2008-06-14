class Apotomo::ChildSwitchWidget < Apotomo::StatefulWidget
  
  def select_content
    @current_child  = find_current_child
  end
  
    
    
    def find_current_page
      param_value = param(param_name_for_current_page)
      begotten_children.find{ |child| child.name.to_s ==  param_value } || default_page
    end
    
    
    def param_name_for_current_page
      name.to_s + "_page"
    end
end
