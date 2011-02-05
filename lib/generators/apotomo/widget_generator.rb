require 'generators/cells/base'

module Apotomo
  module Generators
    class WidgetGenerator < ::Cells::Generators::Base
      source_root File.expand_path(File.join(File.dirname(__FILE__), '../templates'))
      
      def create_cell_file
        template 'widget.rb', File.join('app/cells', class_path, "#{file_name}.rb")
      end
      
      hook_for(:template_engine)
      hook_for(:test_framework)  # TODO: implement rspec-apotomo.
    end
  end
end
