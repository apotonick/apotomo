module Apotomo
  class WidgetRenderBuffer
    def initialize w
      @widget = w
      @buffer = ""
    end

    def replace *args
      @buffer << @widget.replace(*args)
    end

    def render *args
      @buffer << @widget.render(@args)
    end

    def to_s
      @buffer
    end
  end
end