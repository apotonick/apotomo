module Apotomo
  # Render Buffer functionality
  module RenderBuffer
    # Returns concatenation of render strings.
    #
    # You can render multiple using a proxy <tt>buf</tt>.
    # If you do <tt>buf << some_string</tt> then <tt>some_string</tt> is concatenated to buffer.
    # And <tt>buf.some_method(...)</tt> is equivalent to <tt>buf << self.some_method(...)</tt>.
    #
    # Example:
    #
    #   render_buffer do |buf|
    #     buf.replace("##{widget_id}", :view => :display)
    #     buf << replace("section#invite", :text => "")
    #   end
    #
    # is equivalent to
    #
    #   replace("##{widget_id}", :view => :display) + replace("section#invite", :text => "")
    def render_buffer
      buffer = RenderBufferProxy.new(self)
      yield buffer
      buffer.to_s
    end
  end

  # Proxy class for RenderBuffer#render_buffer
  class RenderBufferProxy
    def initialize(output_widget)
      @widget = output_widget
      @buffer = ""
    end

    def <<(str)
      @buffer << str
    end

    def method_missing(method_name, *args)
      @buffer << @widget.send(method_name, *args)
    end

    def to_s
      @buffer.to_s
    end
  end
end
