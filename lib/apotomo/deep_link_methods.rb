module Apotomo
  module DeepLinkMethods
    def self.included(base)
      base.initialize_hooks << :initialize_deep_link_for
    end
    
    
    # Called in StatefulWidget's constructor.
    def initialize_deep_link_for(id, start_states, opts)
      #add_deep_link if opts[:is_url_listener] ### DISCUSS: remove #add_de
    end
    
    def responds_to_url_change?
      evt_table.all_handlers_for(:urlChange, name).size > 0
    end
    
    
    ### DISCUSS: private? rename to compute_url_fragment_for ?
    # Computes the fragment part of the widget's url by querying all widgets up to root.
    # Widgets managing a certain state will usually insert state recovery information
    # via local_fragment.
    def url_fragment_for(local_portion=nil, portions=[])
      local_portion = local_fragment if responds_to_url_change? and local_portion.nil?
      
      portions.unshift(local_portion) # prepend portions as we move up.
      
      return portions.compact.join("/") if root?
      
      parent.url_fragment_for(nil, portions)
    end
    
    
    # Called when widget :is_url_listener. Adds the local url fragment portion to the url.
    def local_fragment
      #"#{local_fragment_key}=#{state_name}"
    end
    
    # Key found in the url fragment, pointing to the local fragment.
    #def local_fragment_key
    #  name
    #end
    
    
    # Called by DeepLinkWidget#process to query if we're involved in an URL change.
    # Do return false if you're not interested in the change.
    #
    # This especially means:
    #  * the fragment doesn't include you or is empty
    #   fragment[name].blank?
    #  * your portion in the fragment didn't change
    #   tab=first/content=html vs. tab=first/content=markdown
    #   fragment[:tab] != @active_tab
    def responds_to_url_change_for?(fragment)
    end
    
    
    
    class UrlFragment
      attr_reader :fragment
      
      def initialize(fragment)
        @fragment = fragment || ""
      end
      
      def to_s
        fragment.to_s
      end
      
      def blank?
        fragment.blank?
      end
      
      ### TODO: make path separator configurable.
      def [](key)
        if path_portion = fragment.split("/").find {|i| i.include?(key.to_s)}
          return path_portion.sub("#{key}=", "")
        end
        
        nil
      end
    end
    
    # Query object for the url fragment. Use this to retrieve state information from the
    # deep link.
    def url_fragment
      UrlFragment.new(param(:deep_link))
    end
    
  end
end