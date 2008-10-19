# Introduces caching of rendered state views into the StatefulWidget.
module Apotomo::Caching
    
  def self.included(base) #:nodoc:
    base.class_eval do
      extend ClassMethods
    end
  end


  module ClassMethods
    # If <tt>version_proc</tt> is omitted, Apotomo provides some basic caching 
    # mechanism: the state view rendered for <tt>state</tt> will be cached as long
    # as you (or e.g. an EventHandler) calls #dirty!. It will then be re-rendered
    # and cached again.
    # You may override that to provide fine-grained caching, with multiple cache versions
    # for the same state.
    def cache(state, version_proc=:cache_version)
      super(state, version_proc)
    end
  end
  
  def cache_version
    @version ||= 0
    {:v => @version}
  end
  
  def increment_version
    @version += 1
  end
  
  # Instruct caching to re-render all cached state views.
  def dirty!
    increment_version
  end
  
end
