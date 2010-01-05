module Apotomo
  module DeepLinkMethods
    
    def self.included(base)
      base.extend(ClassMethods)
      
      base.initialize_hooks << :initialize_deep_link_for
    end
    
    module ClassMethods
      def adds_deep_link(portion=true)  ### DISCUSS: pass block to customize portion?
        @class_local_fragment = portion
      end
      
      def class_local_fragment
        @class_local_fragment
      end
    end
    
    # Called in StatefulWidget's constructor.
    def initialize_deep_link_for(id, start_states, opts)
      add_deep_link if opts[:is_url_listener] ### DISCUSS: remove #add_deep_link ?
    end
    
    def adds_deep_link?
      @local_fragment || self.class.class_local_fragment
    end
    
    def local_fragment
      "#{name}=#{state_name}"
    end
    
    # Computes the fragment part of the widget's url by querying all widgets up to root.
    # Widgets managing a certain state will usually insert state recovery information
    # via local_fragment.
    def url_fragment(portions=[], local_portion=nil)
      local_portion = local_fragment if adds_deep_link? and local_portion.nil?
      
      portions.unshift(local_portion) # prepend portions as we move up.
      
      return portions.compact.join("/") if isRoot?
      
      parent.url_fragment(portions)
    end
    
    def url_fragment_with(local_portion)
      url_fragment([], local_portion)
    end
    
    private
      def add_deep_link(portion=true)
        @local_fragment = portion
      end
  end
end