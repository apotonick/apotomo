require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


# fixture:
class MyTestCell < Apotomo::StatefulWidget
  def widget_content
    render
  end
  
  def a_state
    "a_state"
  end
end


class StatefulWidgetTest < ActionController::TestCase
  include Apotomo::UnitTestCase
  
  def test_visibility
    p= cell(:my_test, :widget_content, 'my_test')
      p << cell(:my_test, :widget_content, 'my_test1')
      p << w= cell(:my_test, :widget_content, 'my_test2')
      p << cell(:my_test, :widget_content, 'my_test3')
    
    w.invisible!
    
    c = p.invoke
    assert_selekt c, "#my_test>#my_test1"
    assert_selekt c, "#my_test>#my_test3"
    assert_selekt c, "#my_test>#my_test2", 0
  end
  
  
  def test_merge_rendered_children_with_locals
    w = cell(:my_test, :widget_content, 'my_test')
    
    assert_equal( {:rendered_children => []},
                  w.prepare_locals_for(nil, []) )
                  
    assert_equal( {:key => :value, :rendered_children => []},
                  w.prepare_locals_for({:key => :value}, []) )
    
    assert_equal( {:rendered_children => ""},
                  w.prepare_locals_for({:rendered_children => ""}, []) )
  end
end
