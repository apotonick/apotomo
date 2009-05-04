require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


# fixture:
class MyTestCell < Apotomo::StatefulWidget
  def a_state
    "a_state"
  end
end

class MyTestWidgetTree < Apotomo::WidgetTree  
  def draw(root)
    root << widget('apotomo/stateful_widget', :widget_content, 'widget_one')
    root << cell(:my_test, :a_state, 'my_test_cell')
    root << switch('my_switch') << widget('apotomo/stateful_widget', :widget_content, :child_widget)
    root << section('my_section')
    root << widget('apotomo/stateful_widget', :widget_content, :widget_three)
    
    root << widget('apotomo/stateful_widget', :widget_content, 'widget_in_app_tree')
  end
end

  
class WidgetTreeTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def test_draw
    r = apotomo_root_mock
    MyTestWidgetTree.new.draw(r)
    
    assert_kind_of Apotomo::StatefulWidget, r.find_by_id('widget_one')
    assert_kind_of Apotomo::StatefulWidget, r.find_by_id('my_test_cell')
    assert_kind_of Apotomo::ChildSwitchWidget, r.find_by_id('my_switch')
    assert_kind_of Apotomo::SectionWidget, r.find_by_id('my_section')
  end
  
end
