require 'generators/cells/base'

module Erb
  module Generators
    class WidgetGenerator < ::Cells::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)

      def create_views
        for state in actions do
          @state = state
          @path = File.join('app/widgets', file_name, "#{state}.html.erb")
          template "view.erb", @path
        end
      end
    end
  end
end
