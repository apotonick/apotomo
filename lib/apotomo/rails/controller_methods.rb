require 'apotomo/request_processor'
require 'uber/inheritable_attr'

module Apotomo
  module Rails
    # Lazy-loads Apotomo support into controllers when needed.
    module ControllerMethodsLoader
      def has_widgets(*args, &block)
        include ControllerMethods
        has_widgets(*args, &block)
      end
    end


    module ActionViewMethods
      delegate :render_widget, :url_for_event, :to => :controller
    end

    module ControllerMethods
      include WidgetShortcuts
      extend ActiveSupport::Concern

      included do
        extend Uber::InheritableAttr
        extend WidgetShortcuts

        inheritable_attr :has_widgets_blocks
        self.has_widgets_blocks = []

        helper ActionViewMethods
      end

      module ClassMethods
        # Yields the root widget to setup your widgets for a controller. The block is executed in
        # controller _instance_ context, so you may use instance methods and variables of the
        # controller.
        #
        # Example:
        #   class PostsController < ApplicationController
        #     has_widgets do |root|
        #       root << widget(:comments, :user => current_user)
        #     end
        def has_widgets(&block)
          has_widgets_blocks << block
        end
      end

      def apotomo_request_processor
        return @apotomo_request_processor if @apotomo_request_processor

        # happens once per request:
        options = {:js_framework   => Apotomo.js_framework}

        @apotomo_request_processor = Apotomo::RequestProcessor.new(self, options, self.class.has_widgets_blocks)
      end

      def apotomo_root
        apotomo_request_processor.root
      end

      def render_widget(*args, &block)
        apotomo_request_processor.render_widget_for(*args, &block)
      end

      def render_event_response
        page_updates = apotomo_request_processor.process_for(params)

        return render_iframe_updates(page_updates) if params[:apotomo_iframe]

        render :text => page_updates.join("\n"), :content_type => Mime['js']
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
      # Renders the page updates through an iframe. Copied from responds_to_parent,
      # see http://github.com/markcatley/responds_to_parent .
      def render_iframe_updates(page_updates)
        escaped_script = Apotomo::JavascriptGenerator.escape(page_updates.join("\n"))

        render :text => "<html><body><script type='text/javascript' charset='utf-8'>
var loc = document.location;
with(window.parent) { setTimeout(function() { window.eval('#{escaped_script}'); window.loc && loc.replace('about:blank'); }, 1) }
</script></body></html>", :content_type => 'text/html'
      end
    end
  end
end
