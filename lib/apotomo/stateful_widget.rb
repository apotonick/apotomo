require 'apotomo/widget'
require 'apotomo/persistence'

module Apotomo
  class StatefulWidget < Widget
    include Persistence
    
    attr_accessor :version
    
    def initialize(*)
      super
      @version = 0
    end
    
    
    # Defines the instance vars that should <em>not</em> survive between requests, 
    # which means they're not frozen in Apotomo::StatefulWidget#freeze.
    def ivars_to_forget
      unfreezable_ivars
    end
    
    def unfreezable_ivars
      [:@childrenHash, :@children, :@parent, :@parent_controller, :@_request, :@_config, :@cell, :@invoke_block, :@rendered_children, :@page_updates, :@opts, :@params,
      :@suppress_javascript ### FIXME: implement with ActiveHelper and :locals.
      
      ]
    end
  end
end
