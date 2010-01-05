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
    p= mouse_mock('mommy', :posing) { def posing; render; end }
      p <<    mouse_mock('jerry')
      p << w= mouse_mock('berry')
      p <<    mouse_mock('larry')
    
    w.invisible!
    
    c = p.invoke
    assert_selekt c, "#mommy>#jerry"
    assert_selekt c, "#mommy>#larry"
    assert_selekt c, "#mommy>#berry", 0
  end
  
  
  def test_find_widget
    r = mouse_mock('root')
      r << b= mouse_mock('berry')
      r << s= mouse_mock('larry')
    
    assert_equal b, s.find_widget('berry')
  end
  
  
  def test_merge_rendered_children_with_locals
    w = mouse_mock
    
    assert_equal( {:rendered_children => []},
                  w.prepare_locals_for(nil, []) )
                  
    assert_equal( {:key => :value, :rendered_children => []},
                  w.prepare_locals_for({:key => :value}, []) )
    
    assert_equal( {:rendered_children => ""},
                  w.prepare_locals_for({:rendered_children => ""}, []) )
  end
  
  
  def test_initialize_hooks
    k = mouse_class_mock do
      self.initialize_hooks << :initialize_mouse
    end
    
    
    assert_equal 2, Apotomo::StatefulWidget.initialize_hooks.size
    assert_equal 3, k.initialize_hooks.size
  end
  
  
  def test_process_initialize_hooks
    k = mouse_class_mock do
      attr_accessor :counter
      
      self.initialize_hooks << :increment_counter
      
      define_method(:increment_counter){@counter ||= 0; @counter += 1}
    end
    
    
    assert_equal 1, k.new(nil, nil).counter, "#increment_counter should have been invoked only once"
    
    k.class_eval do
      self.initialize_hooks << :increment_counter
    end
    
    assert_equal 2, k.new(nil, nil).counter, "#increment_counter hasn't been invoked twice"
  end
end
