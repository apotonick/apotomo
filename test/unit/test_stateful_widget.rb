require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


# fixture:
class MyTestCell < Apotomo::StatefulWidget
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
end
