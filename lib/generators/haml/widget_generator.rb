require 'generators/haml/cell_generator'
require 'generators/apotomo/widget_generator'

module Haml
  module Generators
    class WidgetGenerator < CellGenerator
      include ::Apotomo::Generators::BasePathMethods
      source_root File.expand_path('../../templates', __FILE__)
    end
  end
end
