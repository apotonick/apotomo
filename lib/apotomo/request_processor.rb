module Apotomo
  class RequestProcessor
    include WidgetShortcuts
    
    attr_reader :session, :root
    
    def initialize(session, options={})
      @session      = session
      @tree_flushed = false
      
      if options[:flush_tree].blank? and session['apotomo_root']
        @root = session['apotomo_root']
      else
        @root = flushed_root 
      end
      
      handle_version!(options[:version])
    end
    
    def flushed_root
      @tree_flushed = true
      widget('apotomo/stateful_widget', :content, 'root')
    end
    
    def handle_version!(version)
      return if version.blank?
      return if root.version == version
      
      @root = flushed_root
      @root.version = version
    end
    
    def tree_flushed?;  @tree_flushed; end
    
    ### TODO: move controller dependency to rails/merb/sinatra layer only!
    def process_event_request_for(request_params, controller)
      self.root.controller = controller
      
      source = self.root.find_by_id(request_params[:source])
      
      source.fire(request_params[:type].to_sym)
      source.root.page_updates ### DISCUSS: that's another dependency.
    end
  end
end