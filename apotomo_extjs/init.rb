# include the simplified widget constructors in the WidgetTree:

::Apotomo::WidgetTree.class_eval do
  include ::Apotomo::ExtjsWidgetTreeMethods
end
