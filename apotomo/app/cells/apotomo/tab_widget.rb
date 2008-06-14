module Apotomo
  class TabWidget < StatefulWidget
    
    def title
      @opts[:title] || name.to_s
    end
    
  end
end
