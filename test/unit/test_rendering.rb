require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class RenderingTestWidget < Apotomo::StatefulWidget
  attr_reader :brain
  attr_reader :rendered_children
  
  def check_state   # view resides in fixtures/apotomo/stateful_widget/
    @ivar = "#{@name} is cool."
    nil
  end
end


class ApotomoRenderingTest < ActionController::TestCase
  include Apotomo::UnitTestCase
  
  Cell::Base.view_paths << File.expand_path(File.dirname(__FILE__) + "/../fixtures")
  
  
  
  def test_assigns_in_view
    w = widget(:rendering_test_widget, :check_state, 'my_widget')
    c = w.invoke
    
    # there should be exactly two variables exposed in the view:
    assert_selekt c, "#my_widget", "my_widget is cool."
    
    assert w.brain.include?('@ivar')
    assert ! w.ivars_to_ignore.include?('@rendered_children') # we want that in the view!
  end
  
  
  def test_rendered_children
    w = widget(:rendering_test_widget, :check_state, 'a')
    w << widget(:rendering_test_widget, :check_state, 'b')
    w << widget(:rendering_test_widget, :check_state, 'c')
    c = w.invoke
    
    # test if rendered_children is an ordered hash, since some widgets need the order:
    r = w.rendered_children.to_a
    assert_equal 'b',   r[0].first
    assert_equal 'c',   r[1].first
  end
end
