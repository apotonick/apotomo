require 'generators/cells/base'

module Apotomo
  module Generators
    module BasePathMethods
      private
        def base_path
          File.join('app/widgets', class_path, file_name)
        end
    end
    
    module Views
      def create_views
        for state in actions do
          @state  = state
          @path   = File.join(base_path, 'views', "#{state}.html.#{handler}")  #base_path defined in Cells::Generators::Base.
          template "view.#{handler}", @path
        end
      end
    end
        
    
    class WidgetGenerator < ::Cells::Generators::Base
      include BasePathMethods
      
      source_root File.expand_path('../../templates', __FILE__)
      
      hook_for(:template_engine)
      hook_for(:test_framework)
      
      check_class_collision :suffix => "Widget"
      
      
      def create_cell_file
        template 'widget.rb', File.join('app/widgets', class_path, file_name, "#{file_name}_widget.rb")
      end
    end
  end
end
