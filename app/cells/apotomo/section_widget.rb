module Apotomo
  class SectionWidget < StatefulWidget
    def widget_content
      render :text => render_children_for(:widget_content, {}).collect{|v| v.last}.join("\n")
    end
  end
end
