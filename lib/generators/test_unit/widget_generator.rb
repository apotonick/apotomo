require 'generators/cells/base'

module TestUnit
  module Generators
    class WidgetGenerator < ::Cells::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)

      def create_test
        @states = actions
        template 'widget_test.rb', File.join('test/widgets/', "#{file_name}_test.rb")
      end
    end
  end
end
