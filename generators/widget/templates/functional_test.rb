require File.expand_path(File.dirname(__FILE__) + "/../../vendor/plugins/apotomo/test/test_helper")

class <%= class_name %>CellTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase

  # Repeat: "I love tests."
  def test_widget
    t = ApplicationWidgetTree.new(controller).draw_tree
    
    # simulate a request:
    t = hibernate_tree(t)
    
  end
end
