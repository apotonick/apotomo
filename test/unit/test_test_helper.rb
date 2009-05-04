require File.expand_path(File.dirname(__FILE__) + "/../test_helper")



class TestHelperTest < ActionController::TestCase
  include Apotomo::UnitTestCase
  
  def test_hibernate_tree
    w = cell(:rendering_test, :widget_content, 'dad')
      w << cell(:rendering_test, :widget_content, 'son')
    w = hibernate_widget(w)
    
    assert_equal  "dad",                w.name
    assert_equal  "son",                w.children.first.name
    assert_kind_of   RenderingTestCell,  w
    
    ### TODO: test controller
  end
  
  def test_test_apotomo_root
    assert_kind_of Apotomo::StatefulWidget, apotomo_root_mock
    assert_equal   [], apotomo_root_mock.children
  end
end