class Apotomo::ChildSwitchWidget < Apotomo::StatefulWidget
  
  attr_reader :current_child_id
  
  def transition_map 
    {
    :switch => [:_switch],
    :_switch => [:_switch],
    }
  end
  
  def switch
    @current_child_id  = find_current_child_id
    #puts "current child:"+@current_child_id.to_s
    
    nil
  end
  
  def _switch

    @current_child_id  = find_current_child_id
    
    state_view :switch
  end
  
  def children_to_render
    [children.find{ |c| c.name == @current_child_id } ]
  end
  
  def find_current_child
    child_id = param(param_name_for_current_child)
    #puts param_name_for_current_child
    #puts child_id
    #puts :xo
    find_child_for_id(child_id) || find_child_for_id(@current_child_id) || default_child
  end
  
  def find_current_child_id
    find_current_child.name
  end
  
  def default_child
    children.first
  end
  
  def param_name_for_current_child
    name.to_s + "_child"
  end
  
  
  def find_child_for_id(id)
    children.find{ |c| c.name.to_s ==  id }
  end
  
  
  # @test: test_tab_panel_widget#test_switch_addressing
  
  def local_address(target, way, state)
    #return super(target, way, state) if target == self
    #return {param_name_for_current_child => target.name} if target == self
    return {param_name_for_current_child => find_current_child_id} if target == self
    
    while target.parent != self
      target = target.parent
    end
    
    {param_name_for_current_child => target.name}
  end
    
end
