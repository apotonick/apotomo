class Apotomo::DeepLinkWidget < Apotomo::StatefulWidget
  
  transition :from => :setup, :to => :process
  transition :in   => :process
  
  def setup
    root.respond_to_event :externalChange, :on => 'deep_link', :with => :process
    root.respond_to_event :internalChange, :on => 'deep_link', :with => :process
    
    render
  end
  
  def process
    # find out what changed in the deep link
      # find the update root (### DISCUSS: this might be more than one root, as in A--B)
    path = param(:deep_link)  # path is #tab=users/icon=3
    
    update_root = root.find {|w| w.adds_deep_link? and w.recognizes_path?(path)}  ### DISCUSS: we just look for one root here.
    
    update_root.trigger(:urlChanged) if update_root
    
    render :nothing => true
  end
end
