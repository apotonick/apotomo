module Apotomo
  module Content
    # Keeps the new content for a widget that updated with #render.
    class PageUpdate < String
      attr_reader :target, :replace
      
      def initialize(options)
        super(options[:with] || "")
        
        @target   = options[:replace] || options[:replace_html]
        raise "Please specify a target widget id" unless @target
        
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
    
    # Keeps the Javascript to be injected in the page for a widget that called 
    # <tt>render :js => ...</tt>.
    class Javascript < ActiveSupport::JSON::Variable
    end
    
    # Keeps the data to be sent to the browser for a widget that called <tt>render :raw => ...</tt>.
    class Raw < String
    end
  end
end