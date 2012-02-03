require 'generators/slim/cell_generator'
require 'generators/apotomo/widget_generator'

module Slim
  module Generators
    class WidgetGenerator < CellGenerator
      include ::Apotomo::Generators::BasePathMethods
      include ::Apotomo::Generators::Views
      source_root File.expand_path('../../templates', __FILE__)
    end
  end
end
