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
      add_deep_link if opts[:is_url_listener] ### DISCUSS: remove #add_de
    end
    
    def adds_deep_link?
      @local_fragment || self.class.class_local_fragment
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
    
    
    
    def local_fragment
      "#{local_fragment_key}=#{state_name}"
    end
    
    # Key found in the url fragment, pointing to the local fragment.
    def local_fragment_key
      name
    end
    
    ### DISCUSS: this is "routing", somehow.
    # Tries to find a corresponding directory in the url fragment
    # and returns the value.
    def local_value_for_path(path)
      return if path.blank?
      
      if path_portion = path.split("/").find {|i| i.include?(local_fragment_key)}
        return path_portion.sub("#{local_fragment_key}=", "")
      end
    end
    
    
    def responds_to_url_change_for?(path)
      return unless adds_deep_link?
      return unless value = local_value_for_path(path)
      
      responds_to_local_fragment_value?(value)
    end
    
    # Decider to find out whether the local url fragment really asks
    # for an update.
    # Overwrite to change the local fragment.
    def responds_to_local_fragment_value?(value)
      value.to_s != last_state.to_s # respond if the current value differs from the last state.
    end
    
    
    private
      def add_deep_link(portion=true)
        @local_fragment = portion
      end
  end
end