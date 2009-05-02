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
  
  
  def test_application_widget_tree_including
    t = Apotomo::WidgetTree.new.reconnect("controller").init!
    assert ! t.root.find_by_id('widget_in_app_tree')
    
    ::ApplicationWidgetTree.class_eval do
      def draw(root)
        root << widget('apotomo/stateful_widget', :widget_content, 'widget_in_app_tree')
      end
    end
    
    t.include_application_widget_tree!
    assert t.root.find_by_id('widget_in_app_tree')
  end
  
  def test_init!
    t = MyTestWidgetTree.new()
    assert_nil    t.controller
    
    t.reconnect("controller")
    assert_equal  "controller", t.controller
    assert_nil    t.root
    
    t.init!
    assert t.root
    assert_equal  "__root__",   t.root.name
    assert_equal  "controller", t.root.controller
  end
  
  def test_initialization
    tree = MyTestWidgetTree.new.reconnect(controller).init!
    
    r = tree.root
    assert_kind_of Apotomo::StatefulWidget, r.find_by_id('widget_one')
    assert_kind_of Apotomo::StatefulWidget, r.find_by_id('my_test_cell')
    assert_kind_of Apotomo::ChildSwitchWidget, r.find_by_id('my_switch')
    assert_kind_of Apotomo::SectionWidget, r.find_by_id('my_section')
  end
  
end
