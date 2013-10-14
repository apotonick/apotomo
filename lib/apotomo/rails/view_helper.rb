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
      delegate :children, :url_for_event, :widget_id, :to => :controller

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

      # Wraps your widget content in a +div+. See #widget_tag.
      def widget_div(*args, &block)
        widget_tag(:div, *args, &block)
      end

      # Wraps your widget content in a +tag+ tag and sets the id. Feel free to pass additional html options.
      #
      #   - widget_tag :span do
      #     %p I'm wrapped
      #
      # will render
      #
      #   <span id="mouse">
      #     <p>I'm wrapped</p>
      #   </span>
      #
      # Note that you can set the +id+ and other options manually.
      #
      #   - widget_tag :div, id: "comments", class: "yellow"
      def widget_tag(tag, options={}, &block)
        options.reverse_merge!(:id => widget_id)

        content_tag(tag, options, &block)
      end
    end
  end
end
