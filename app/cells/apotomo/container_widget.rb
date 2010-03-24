module Apotomo
  class ContainerWidget < StatefulWidget
    def display
      render :text => render_children.collect{|v| v.last}.join("\n"), :frame => :div, :render_children => false
    end
  end
end
