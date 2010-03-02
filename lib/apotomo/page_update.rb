module Apotomo
  class PageUpdate < String
    attr_reader :target, :content, :replace
    
    def initialize(options)
      @target   = options[:replace] || options[:replace_html]
      raise RuntimeError unless @target
      
      @replace  = options[:replace]
      @content  = options[:with] || ""
    end
    
    def replace?
      @replace
    end
    
    def replace_html?
      not replace?
    end
    
    def to_s
      @content
    end
    
    def inspect
      '"'+to_s+'"'
    end
    
    def ==(obj)
      [@target, @content, @replace] == [obj.target, obj.content, obj.replace]
    end
  end
end