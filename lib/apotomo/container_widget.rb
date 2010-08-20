require 'apotomo/widget'

module Apotomo
  class ContainerWidget < Widget
    def display
      content = render_children.collect{ |v| v.last }.join("\n")
      render :text => "<div id=\"#{self.name}\">#{content}</div>"
    end
  end
end
