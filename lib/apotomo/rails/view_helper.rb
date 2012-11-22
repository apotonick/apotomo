module Apotomo
  module Rails
    # == #url_for_event
    #
    #   = url_for_event(:paginate, :page => 2)
    #   #=> http://apotomo.de/mouse/process_event_request?type=paginate&source=mouse&page=2
    #
    # == #widget_id
    #
    #   = widget_id
    #   #=> :mouse
    #
    # == #children
    #
    #   - children.each do |kid|
    #     = render_widget kid
    module ViewHelper
      autoload :DragnDrop, 'apotomo/rails/view_helper/dragn_drop'
      autoload :Ajax,      'apotomo/rails/view_helper/ajax'

      delegate :children, :url_for_event, :widget_id, :to => :controller
      
      include DragnDrop, Ajax

      # Returns the app JavaScript generator.
      def js_generator
        Apotomo.js_generator
      end
            
      # Creates a form that submits itself via an iFrame and executes the response
      # in the parent window. This is needed to upload files via AJAX.
      #
      # Better call <tt>#form_to_event :multipart => true</tt> and stay forward-compatible.
      def multipart_form_to_event(type, options={}, html_options={}, &block)
        options.reverse_merge!      :apotomo_iframe => true
        html_options.reverse_merge! :target         => :apotomo_iframe, :multipart => true
        
        # i hate rails:
        concat('<iframe id="apotomo_iframe" name="apotomo_iframe" style="display: none;"></iframe>'.html_safe) << form_tag(url_for_event(type, options), html_options, &block)
      end
      
      # Wraps your content in a +div+ and sets the id. Feel free to pass additional html options.
      #
      # Example:
      #
      #   - widget_div do
      #     %p I'm wrapped
      #
      # will render
      #
      #   <div id="mouse">
      #     <p>I'm wrapped</p>
      #   </div>
      def widget_div(options={}, &block)
        options.reverse_merge!(:id => widget_id) 
        content_tag(:div, options, &block)
      end
    end
  end
end
