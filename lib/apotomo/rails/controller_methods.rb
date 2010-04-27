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
          ### DISCUSS: policy in production?
          options = { :flush_widgets  => params[:flush_widgets],
                      :js_framework   => Apotomo.js_framework || :prototype,
          }  ### TODO: process rails options (flush_tree, version)
          
          @apotomo_request_processor = Apotomo::RequestProcessor.new(session, options)
          
          flush_bound_use_widgets_blocks if @apotomo_request_processor.widgets_flushed?
          
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
          root = apotomo_root ### DISCUSS: let RequestProcessor initialize so we get flushed, eventually. maybe add a :before filter for that? or move #use_widgets to RequestProcessor?
          
          return if bound_use_widgets_blocks.include?(block)
          
          yield root
          
          bound_use_widgets_blocks << block  # remember the proc.
        end
        
        
        def render_widget(widget, options={}, &block)
          apotomo_request_processor.render_widget_for(widget, options, self, &block)
        end
        
        def apotomo_freeze
          apotomo_request_processor.freeze!
        end
      
        def render_event_response
          page_updates = apotomo_request_processor.process_for({:type => params[:type], :source => params[:source]}, self)
          
          ### DISCUSS: how to properly handle multiple/mixed contents (raw data, page updates)? 
          return render_raw(page_updates) if page_updates.first.kind_of? Apotomo::Content::Raw
          
          return render_iframe_updates(page_updates) if params[:apotomo_iframe]
          
          render :text => apotomo_request_processor.render_page_updates(page_updates), :content_type => Mime::JS
        end
        
        # Returns the url to trigger a +type+ event from +:source+, which is a non-optional parameter.
        # Additional +options+ will be appended to the query string.
        #
        # Note that this method will use the framework's internal routing if available (e.g. #url_for in Rails).
        #
        # Example:
        #   url_for_event(:paginate, :source => 'mouse', :page => 2)
        #   #=> http://apotomo.de/mouse/process_event_request?type=paginate&source=mouse&page=2
        def url_for_event(type, options)
          options.reverse_merge!  :action     => :render_event_response,
                                  :type       => type,
                                  :only_path  => true
          url_for apotomo_request_processor.address_for(options)
        end
        
        protected
        
        # Returns the raw content to the browser. This is needed when a widget send data to its
        # JavaScript model in the browser, eg when paging a grid.
        def render_raw(data)
          render :text => data.first
        end
        
        # Renders the page updates through an iframe. Copied from responds_to_parent,
        # see http://github.com/markcatley/responds_to_parent .
        def render_iframe_updates(page_updates)
          script = apotomo_request_processor.render_page_updates(page_updates)
          escaped_script = apotomo_request_processor.js_generator.escape(script)
          
          render :text => "<html><body><script type='text/javascript' charset='utf-8'>
var loc = document.location;
with(window.parent) { setTimeout(function() { window.eval('#{escaped_script}'); window.loc && loc.replace('about:blank'); }, 1) }
</script></body></html>", :content_type => 'text/html'
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
          return if apotomo_root.find_widget('deep_link')  # add only once.
          apotomo_root << widget("apotomo/deep_link_widget", :setup, 'deep_link')
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