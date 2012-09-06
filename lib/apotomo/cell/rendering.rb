module Cell
  module Rendering
    def render(*args)
      view_name = File.join('views', self.action_name)
      render_view_for(view_name, *args)
    end
  end
end