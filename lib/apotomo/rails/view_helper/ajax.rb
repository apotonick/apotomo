module Apotomo::Rails::ViewHelper
  module Ajax
    # fx
    # ajax_url "#trashbin", "&id=" + ui.draggable.attr("data-id")
    def ajax_url selector, params
      %Q{jQuery.ajax({url: jQuery("#{selector}").attr("data-event-url") + #{params};})}
    end
  end
end
