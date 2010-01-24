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
    #path = param(:deep_link)  # path is #tab=users/icon=3
    
    update_root = root.find {|w| w.responds_to_url_change? and w.responds_to_url_change_for?(url_fragment)}  ### DISCUSS: we just look for one root here.
    
    if update_root
      controller.logger.debug "deep_link#process: `#{update_root.name}` responds to :urlChange"
      update_root.trigger(:urlChange)
    end
    
    render :nothing => true
  end
end
