module Apotomo
  module Rails
    module ViewMethods
      def render_widget(*args)
        controller.render_widget(*args)
      end
    end
  end
end