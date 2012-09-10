module Cell
  module Rendering
    def render(*args)
      if args.first.kind_of?(Hash) 
        if args.first[:view]
          hash = args.first
          hash[:view] = File.join('views', hash[:view].to_s)
          args = [hash, args[1..-1]]
        end
        if args.first[:partial]
          view_name = self.action_name || ''
        end
      end
      
      view_name ||= File.join('views', self.action_name || '')
      render_view_for(view_name, *args)
    rescue
      # try without view
      view_name = view_name.gsub(/views\//, '')
      if args.first.kind_of?(Hash) && args.first[:view]
        hash = args.first
        hash[:view] = File.join(hash[:view].to_s)
        args = [hash, args[1..-1]]
      end
      render_view_for(view_name, *args)
    end
  end
end