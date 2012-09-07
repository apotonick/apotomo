module Cell
  module Rendering
    def render(*args)
      puts "render: #{args}"

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

      puts "view_name: #{view_name}, #{args}"      
      render_view_for(view_name, *args)
    end
  end
end