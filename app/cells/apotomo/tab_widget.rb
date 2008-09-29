module Apotomo
  class TabWidget < StatefulWidget
    
    attr_accessor :title
    
    def initialize(controller, id, start_states=:widget_content, opts={})
      super(controller, id, start_states, opts)
      
      @title = opts[:title] || name.to_s
    end
    
  end
end
