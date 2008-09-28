require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


# fixture:
class MyTestCell < Apotomo::StatefulWidget
  def a_state
    "a_state"
  end
end

class MyTestWidgetTree < Apotomo::WidgetTree  
  def draw(root)
    root << widget('apotomo/stateful_widget', 'widget_one')
    root << cell(:my_test, :a_state, 'my_test_cell')
    root << switch('my_switch') << widget('apotomo/stateful_widget', :child_widget)
    root << section('my_section')
    root << widget('apotomo/stateful_widget', :widget_three)
    #root  ### FIXME! find a way to return nothing by default.
  end
end


class WidgetTreeTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  
  def test_initialization
    tree = MyTestWidgetTree.new(controller)
    
    r = tree.draw_tree.root
    assert_kind_of Apotomo::StatefulWidget, r.find_by_id('widget_one')
    assert_kind_of Apotomo::StatefulWidget, r.find_by_id('my_test_cell')
    assert_kind_of Apotomo::ChildSwitchWidget, r.find_by_id('my_switch')
    assert_kind_of Apotomo::SectionWidget, r.find_by_id('my_section')
    
    puts r.render_content
  end
  
end
