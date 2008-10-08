require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


# fixture:
module My
  class TestCell < Apotomo::StatefulWidget
    def a_state
      "a_state"
    end
  end
  
  class TestWidget < Apotomo::StatefulWidget
    def a_state
      "a_state"
    end
  end
end

class MyTestWidgetTree < Apotomo::WidgetTree  
  def draw(root)
    root << widget('apotomo/stateful_widget', :widget_content, 'widget_one')
    root << cell(:my_test, :a_state, 'my_test_cell')
    root << switch('my_switch') << widget('apotomo/stateful_widget', :widget_content, :child_widget)
    root << section('my_section')
    root << widget('apotomo/stateful_widget', :widget_content, :widget_three)
    #root  ### FIXME! find a way to return nothing by default.
  end
end


class WidgetShortcutsTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  
  def test_cell
    assert_kind_of My::TestCell, cell("my/test", :a_state, 'my_test_cell')
  end
  
  def test_widget
    w = widget("my/test_widget", :a_state, 'my_test_cell')
    assert_kind_of My::TestWidget, w
    assert_equal "my_test_cell", w.name
  end
  
end
