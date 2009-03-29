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
  
  
  # we only want a small set of ivars exposed in the view.
  def test_assigns_in_view
    w = widget(:rendering_test_widget, :check_state, 'my_widget')
    c = w.invoke
    
    # there should be exactly two variables exposed in the view, 
    # the state ivars and @rendered_children:
    puts "content: #{c}"
    assert_selekt c, "#my_widget", "my_widget is cool."
    assert_equal 1, w.brain.size
    assert w.brain.include?('@ivar')
    assert ! w.ivars_to_ignore.include?('@rendered_children') # we want that in the view!
  end
  
  # is @rendered_children in views a ordered hash?
  def test_rendered_children
    ### TODO: move to abc_tree.
    w = widget(:rendering_test_widget, :widget_content, 'a')
    w << widget(:rendering_test_widget, :widget_content, 'b')
    w << widget(:rendering_test_widget, :widget_content, 'c')
    c = w.invoke
    
    r = w.rendered_children.to_a
    assert_equal 'b',   r[0].first
    assert_equal 'c',   r[1].first
  end
  
  # the default view "widget_content.html.erb" should just concat itself and its children.
  def test_default_widget_content_view
    ### TODO: move to abc_tree.
    w = widget(:rendering_test_widget, :widget_content, 'a')
    w << widget(:rendering_test_widget, :widget_content, 'b')
    w << widget(:rendering_test_widget, :widget_content, 'c')
    c = w.invoke
    
    assert_selekt c, "#a>#b:nth-child(1)"
    assert_selekt c, "#a>#c:nth-child(2)"
  end

end
