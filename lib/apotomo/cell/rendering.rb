module Cell
  module Rendering
    def render(*args)
      if args.first.kind_of?(Hash) && args.first[:view]
        hash = args.first
        hash[:view] = File.join('views', hash[:view].to_s)
        args = [hash, args[1..-1]]
      end
      view_name = File.join('views', self.action_name || '')
      render_view_for(view_name, *args)
    end
  end
end