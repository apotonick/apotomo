class Apotomo::TreeStore < Hash
  def root_item    
    {:text => :root, :leaf => false, :id => :root}
  end
  def items_for_node_id(node_id)  
    node_id = node_id.to_sym
     if node_id == :root
      puts "yo!!!! asking for :root"
      return fetch(:root).collect do |k,v|
        {:text => k, :leaf => v.size > 0 ? false : true, :id => k}
      end  
    end
    
    fetch(:root)[node_id].collect do |k,v|
      {:text => k, :leaf => v.size > 0 ? false : true, :id => k}
    end
  end
end
