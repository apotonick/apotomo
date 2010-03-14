  module Apotomo
    module Rails
      module ControllerMethods
        include WidgetShortcuts
        
        def self.included(base) #:nodoc:
          base.class_eval do
            extend WidgetShortcuts
            
            helper ::Apotomo::Rails::ViewMethods
            
            after_filter :apotomo_freeze
          end
        end
        
        def bound_use_widgets_blocks
          session[:bound_use_widgets_blocks] ||= ProcHash.new
        end
        
        def flush_bound_use_widgets_blocks
          session[:bound_use_widgets_blocks] = nil
        end
        
        def apotomo_request_processor
          return @apotomo_request_processor if @apotomo_request_processor
          
          # happens once per request:
          options = {}  ### TODO: process rails options (flush_tree, version)
          
          @apotomo_request_processor = Apotomo::RequestProcessor.new(session, options)
          
          flush_bound_use_widgets_blocks if @apotomo_request_processor.tree_flushed?
          
          @apotomo_request_processor
        end
        
        def apotomo_root
          apotomo_request_processor.root
        end
        
        # Yields the root widget for manipulating the widget tree in a controller action.
        # Note that the passed block is executed once per session and not in every request.
        #
        # Example:
        #   def login
        #     use_widgets do |root|
        #       root << cell(:login, :form, 'login_box')
        #     end
        #
        #     @box = render_widget 'login_box'
        #   end
        def use_widgets(&block)
          return if bound_use_widgets_blocks.include?(block)
          
          yield apotomo_root
          
          bound_use_widgets_blocks << block  # remember the proc.
        end
        
        
        def render_widget(widget, options={}, &block)
          apotomo_request_processor.render_widget_for(widget, options, self, &block)
        end
        
        def apotomo_freeze
          apotomo_request_processor.freeze!
        end
      
        def render_event_response
          page_updates = apotomo_request_processor.process_event_request_for({:type => params[:type], :source => params[:source]}, self)
          
          render_page_updates(page_updates)
        end
        
        # Computes the url hash to the event processing action. May be passed to url_for. 
        def apotomo_address_for(widget, options)
          options[:action] ||= :render_event_response ### TODO: provide configuration directive.
          widget.address_for_event(options)
        end
        
        
        protected
        
        def render_page_updates(page_updates)
          render :update do |page|
            page_updates.each do |page_update|
              next if page_update.blank?
              
              ### DISCUSS: provide proper PageUpdate API.
              if page_update.kind_of? ActiveSupport::JSON::Variable
                page << "#{page_update}"
              elsif page_update.replace?
                page.replace page_update.target, "#{page_update}"
              elsif page_update.replace_html?
                page.replace_html page_update.target, "#{page_update}"
              end
            end
          end 
        end
        
        
        
        def respond_to_event(type, options)
          handler = ProcEventHandler.new
          handler.proc = options[:with]
          ### TODO: pass :from => (event source).
          
          # attach once, not every request:
          apotomo_root.evt_table.add_handler_once(handler, :event_type => type)
        end
        
        
        
        ### DISCUSS: rename? should say "this controller action wants apotomo's deep linking!"
        ### DISCUSS: move to deep_link_methods?
        def respond_to_url_change
          return if apotomo_root.find_by_id('deep_link')  # add only once.
          apotomo_root << widget("apotomo/deep_link_widget", :setup, 'deep_link')
        end
        
        
        
        
        
        
        
      
      
      
      
      
      
      
      def render_data_for(processed_handlers)
        ### TODO: what if more events have been attached, smart boy?
        Rails.logger.debug "  +++++++++ page updates:"
        Rails.logger.debug processed_handlers.inspect
        (handler, content) = processed_handlers.find {|i| i.last.size > 0}  ### FIXME: how do we know which handler to return? better check for kind_of? Data
        
        render :text => content
      end
      
      
      def render_iframe_update_for(processed_handlers)
        script = ""
      
        processed_handlers.each do |handler, content|
            #content = handler.content
            next unless content
  
            if content.class == String
              script += 'Element.replace("'+handler.widget_id+'", "'+content.gsub('"', '\\\\\"').gsub("\n", "").gsub("'", "\\\\'")+'");'
              #page.replace handler.widget_id, content
            else
              script += content.gsub("\n", "").gsub("'", "\\\\'")
            end
          end
        logger.info script
      
        # stolen from responds_to_parent, thanks sean tradeway and you other guys!
        render :text => "<html><body><script type='text/javascript' charset='utf-8'>
            var loc = document.location;
            with(window.parent) { setTimeout(function() { window.eval('#{script}'); loc.replace('about:blank'); }, 1) } 
          </script></body></html>"
      end
      
      class ProcHash < Array
        def id_for_proc(proc)
          proc.to_s.split('@').last
        end
      
        def <<(proc)
          super(id_for_proc(proc))
        end
        
        def include?(proc)
          super(id_for_proc(proc))
        end
      end
    end
  end
end