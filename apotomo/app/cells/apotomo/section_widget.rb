module Apotomo
  
  class SectionWidget < StatefulWidget
    
    def view_for_state(state)
        #puts "view for state: "+self.name.to_s+" "+state.to_s
        forced_view || super(state)
        #puts view
        #view
      end

      def forced_view
        @opts[:view]
      end
  end
end
