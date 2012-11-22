require 'generators/cells/base'

module TestUnit
  module Generators
    class WidgetGenerator < ::Cells::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)

      def create_test
        @states = actions
        template 'widget_test.rb', File.join(test_path, "#{file_name}_widget_test.rb")
      end

      protected

      def test_path
        File.join('test/widgets/', class_path, file_name)
      end
    end
  end
end
