require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class ApotomoRenderingTest < ActionController::TestCase
  include Apotomo::UnitTestCase  
  
  # we only want a small set of ivars exposed in the view.
  def test_assigns_in_view
    w = mouse_mock('my_widget', :check_state) do
      def brain; @brain; end
      
      def check_state
        @ivar = "#{@name} is cool."
        render
      end
    end
    
    # there should be exactly two variables exposed in the view, 
    # the state ivars and @rendered_children:
    assert_selekt w.invoke, "#my_widget", "my_widget is cool."
    assert_equal 1, w.brain.size
    assert w.brain.include?('@ivar')
    assert ! w.ivars_to_ignore.include?('@rendered_children') # we want that in the view!
  end
  
  # is rendered_children an ordered hash?
  def test_render_children_for_state
    w = mouse_mock('a')
    w << mouse_mock('b')
    w << mouse_mock('c')
    
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
    w.controller = @controller
    c = w.invoke
    
    assert_selekt c, "#a>#b:nth-child(1)"
    assert_selekt c, "#a>#c:nth-child(2)"
  end
  
  def test_render
    assert_selekt mouse_mock.invoke,  "div#mouse", "burp!"
  end
  
  def test_render_with_different_view
    w = mouse_mock('mouse', :drinking) do
      def drinking
        render :view => :eating
      end
    end
    
    assert_selekt w.invoke,  "div#mouse", "burp!"
  end
  
  def test_render_js
    w = mouse_mock do
      def eating
        render :js => "alert();"
      end
    end
    
    c = w.invoke
    assert_kind_of  ActiveSupport::JSON::Variable, c
    assert_equal    "alert();", c.to_s
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
