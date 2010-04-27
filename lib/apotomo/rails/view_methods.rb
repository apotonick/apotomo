module Apotomo
  module Rails
    module ViewMethods
      delegate :render_widget, :url_for_event, :to => :controller
    end
  end
end