module Apotomo
  class SectionWidget < StatefulWidget
    def widget_content
      render :text => render_children.collect{|v| v.last}.join("\n"), :frame => :true
    end
  end
end
