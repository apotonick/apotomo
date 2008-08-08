require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class ChildStatesTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def setup
    super
    @controller.session = {}
    @w  = MyWidget.new(@controller, 'my_widget')
    @c1 = MyWidget.new(@controller, 'child_1')
    @c2 = MyWidget.new(@controller, 'child_2')
    @c3 = MyWidget.new(@controller, 'child_3')
  end
  
  
  def test_explicitly_set_state_for_child
    assert_equal @w.decide_child_state_for(@c1, :top_state), :explicit_state
  end
  
  
  def test_default_state_for_child
    assert_equal @w.decide_child_state_for(@c2, :top_state), "_"
    assert_equal @w.decide_child_state_for(@c1, :unknown_state), "_"
  end
  
  
  def test_explicit_state_for_all_childs
    assert_equal @w.decide_child_state_for(@c1, :second_state), "*"
    assert_equal @w.decide_child_state_for(@c3, :second_state), :second_state_for_child_3
  end
  
  
end


class MyWidget < Apotomo::StatefulWidget
  def child_states
    { :top_state    => {'child_1' => :explicit_state},
      :second_state => {nil       => "*", 
                        'child_3' => :second_state_for_child_3}
    }
  end
end
