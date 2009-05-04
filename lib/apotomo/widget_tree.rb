module Apotomo
  # encapsulates the "global" widget tree which will be available in any controller.
  # should be overwritten and extended in application_widget_tree.rb if needed.
  
  class WidgetTree
    
    include Apotomo::EventAware
    include WidgetShortcuts
    
    attr_reader :controller
    
    def draw(root)
      # define the application widgets attached to root:
      # ...
      
      root
    end
  end
end
