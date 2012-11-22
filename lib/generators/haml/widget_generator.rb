require 'generators/haml/cell_generator'
require 'generators/apotomo/widget_generator'

module Haml
  module Generators
    class WidgetGenerator < CellGenerator
      include ::Apotomo::Generators::BasePathMethods
      include ::Apotomo::Generators::Views      
    end
  end
end
