require 'apotomo/request_processor'
require 'apotomo/rails/view_methods'

  module Apotomo
    module Rails
      module ControllerMethods
        include WidgetShortcuts
        extend ActiveSupport::Concern
        
        included do
          extend WidgetShortcuts
          
          class_inheritable_array :has_widgets_blocks
          self.has_widgets_blocks = []
          
          helper ::Apotomo::Rails::ViewMethods
          
          after_filter :apotomo_freeze
        end
        
        module ClassMethods
          # Yields the root widget to setup your widgets for a controller. The block is executed in 
          # controller _instance_ context, so you may use instance methods and variables of the
          # controller.
          #
          # Example:
          #   class PostsController < ApplicationController
          #     has_widgets do |root|
          #       root << widget(:comments_widget, 'post-comments', :user => @current_user)
          #     end
          def has_widgets(&block)
            has_widgets_blocks << block
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
          
          @apotomo_request_processor = Apotomo::RequestProcessor.new(self, session, options, self.class.has_widgets_blocks)
          
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
        #       root << widget(:login_widget, 'login_box')
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
          apotomo_request_processor.render_widget_for(widget, options, &block)
        end
        
        def apotomo_freeze
          apotomo_request_processor.freeze!
        end
      
        def render_event_response
          page_updates = apotomo_request_processor.process_for({:type => params[:type], :source => params[:source]})
          
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
          options.reverse_merge!(:type => type)
          
          apotomo_event_path(apotomo_request_processor.address_for(options))
        end
        
        protected
        
        def parent_controller
          self
        end
        
        
        
        # Renders the page updates through an iframe. Copied from responds_to_parent,
        # see http://github.com/markcatley/responds_to_parent .
        def render_iframe_updates(page_updates)
          script = apotomo_request_processor.render_page_updates(page_updates)
          escaped_script = Apotomo::JavascriptGenerator.escape(script)
          
          render :text => "<html><body><script type='text/javascript' charset='utf-8'>
var loc = document.location;
with(window.parent) { setTimeout(function() { window.eval('#{escaped_script}'); window.loc && loc.replace('about:blank'); }, 1) }
</script></body></html>", :content_type => 'text/html'
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
