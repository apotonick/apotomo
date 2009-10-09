module Apotomo
  class TabWidget < StatefulWidget
    
    attr_accessor :title
    
    def initialize(id, start_states=:widget_content, opts={})
      super(id, start_states, opts)
      
      @title = opts[:title] || name.to_s
    end
    
  end
end
