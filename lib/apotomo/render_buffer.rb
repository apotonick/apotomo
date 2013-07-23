module Apotomo
  # Proxy class for Widget#render_buffer.
  class RenderBuffer
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
