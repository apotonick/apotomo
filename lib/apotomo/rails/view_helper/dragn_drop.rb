module Apotomo::Rails::ViewHelper
  module DragnDrop
    # fx
    # droppable "#trashbin", ajax_url("#trashbin", "&id=" + ui.draggable.attr("data-id"))
    def droppable selector, &block
      %Q{$("#{selector}").droppable({
  drop: function(event, ui) {
    #{yield}
  }
}}
    end  

    # fx 
    # draggable "##{widget_id} li", {revert: "invalid"}
    def draggable selector, options
      %Q{$(\"#{selector}\").draggable(#{options.to_json});}
    end
  end
end
