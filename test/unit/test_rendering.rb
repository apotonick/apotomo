require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class ApotomoRenderingTest < ActionController::TestCase
  include Apotomo::UnitTestCase  
  
  # we only want a small set of ivars exposed in the view.
  def test_assigns_in_view
    w = cell(:rendering_test, :check_state, 'my_widget')
    c = w.invoke
    
    # there should be exactly two variables exposed in the view, 
    # the state ivars and @rendered_children:
    assert_selekt c, "#my_widget", "my_widget is cool."
    assert_equal 1, w.brain.size
    assert w.brain.include?('@ivar')
    assert ! w.ivars_to_ignore.include?('@rendered_children') # we want that in the view!
  end
  
  # is rendered_children an ordered hash?
  def test_render_children_for_state
    RenderingTestCell.class_eval do
      def widget_content; render; end
    end
    w = cell(:rendering_test, :widget_content, 'a')
    w << cell(:rendering_test, :widget_content, 'b')
    w << cell(:rendering_test, :widget_content, 'c')
    
    rendered_children = w.render_children_for(:widget_content, {})
    
    
    
    r = rendered_children.to_a
    assert_equal 'b',   r[0].first
    assert_equal 'c',   r[1].first
  end
  
  # the default view "widget_content.html.erb" should just concat itself and its children.
  def test_rendered_children_in_view
    RenderingTestCell.class_eval do
      def widget_content; render; end
    end
    
    ### TODO: move to abc_tree.
    w = cell(:rendering_test, :widget_content, 'a')
    w << cell(:rendering_test, :widget_content, 'b')
    w << cell(:rendering_test, :widget_content, 'c')
    c = w.invoke
    
    assert_selekt c, "#a>#b:nth-child(1)"
    assert_selekt c, "#a>#c:nth-child(2)"
  end
  
  def test_render
    RenderingTestCell.class_eval do
      def call_render
        render
      end
    end
    
    c = cell(:rendering_test, :call_render, 'my_cell').invoke
    assert_selekt c,  "div#my_cell", "call_render"
  end
  
  def test_render_with_different_view
    RenderingTestCell.class_eval do
      def call_render
        render :view => :different
      end
    end
    
    c = cell(:rendering_test, :call_render, 'my_cell').invoke
    assert_selekt c,  "div#my_cell", "different"
  end
  
  def test_render_js
    RenderingTestCell.class_eval do
      def call_render
        render :js => "alert();"
      end
    end
    
    c = cell(:rendering_test, :call_render, 'my_cell').invoke
    assert_kind_of  ActiveSupport::JSON::Variable, c
    assert_equal    "alert();", c.to_s
  end

  
  # Provides a ready-to-use mouse widget instance.
  def mouse_mock(id='mouse', start_state=:eating, &block)
    mouse = mouse_class_mock.new(id, start_state)
    mouse.instance_eval &block
    mouse
  end
  
  def mouse_class_mock
    Class.new(MouseCell)
  end
  
  
  def test_html_options
    # state rendering time:
      # with class only:
    c = mouse_mock do 
      def eating
        render :html_options => {:class => :highlighted}
      end
    end.invoke
    assert_selekt c,  "div.highlighted#mouse", "burp!"
    
      # with id and class:
    c = mouse_mock do 
      def eating
        render :html_options => {:class => :highlighted, :id => 'bear'}
      end
    end.invoke
    assert_selekt c,  "div.highlighted#bear", "burp!"
    
    
    return  ### DISCUSS: is it really necessary to define html_options in other places?
    # widget definition time:
    c = cell(:rendering_test, :call_render, 'my_cell', :class => :active).invoke
    assert_selekt c,  "div.active#my_cell", "call_render"
    
    # class compile time:
    klass = Class.new(RenderingTestCell)
    klass.instance_eval do
      html_options = {:class => :blinking}
    end
    
    c = klass.new(:call_render, 'id').invoke
    assert_selekt c,  "div.blinking#my_cell", "call_render"
  end

end
