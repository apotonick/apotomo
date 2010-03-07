module Apotomo
  class PageUpdate < String
    attr_reader :target, :content, :replace
    
    def initialize(options)
      super(options[:with] || "")
      
      @target   = options[:replace] || options[:replace_html]
      raise RuntimeError unless @target
      
      @replace  = options[:replace]
    end
    
    def replace?
      @replace
    end
    
    def replace_html?
      not replace?
    end
    
    def ==(obj)
      [@target, self.to_s, @replace] == [obj.target, obj.to_s, obj.replace]
    end
  end
end