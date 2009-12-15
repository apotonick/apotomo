module Apotomo
  class TabWidget < StatefulWidget
    
    attr_accessor :title
    
    def initialize(*args)
      super(*args)
      
      @title = @opts[:title] || self.name.to_s
    end
    
    
    def display
      render
    end
    
  end
end
