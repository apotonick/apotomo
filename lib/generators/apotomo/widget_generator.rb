require 'generators/cells/cell_generator'

module Apotomo
  module Generators
    class WidgetGenerator < Cells::Generators::CellGenerator
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      
      def create_cell_file
        puts "creating #{file_name}.rb"
        template 'widget.rb', File.join('app/cells', class_path, "#{file_name}.rb")
      end
      
      def create_test
        @states = actions
        template 'widget_test.rb', File.join('test/widgets/', "#{file_name}_test.rb")
      end
    end
  end
end
