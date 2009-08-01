require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class EventMethodsTest < ActionController::TestCase
  include Apotomo::UnitTestCase

  def test_respond_to_event
    w = cell(:rendering_test, :widget_content, 'my_widget')
    t = w.evt_table
    
    # no event handlers in a fresh widget:
    assert_equal(0, t.size)
    
    
    w.respond_to_event :click, :with => :processClick
    assert_equal 1, t.size
    assert_equal t.handlers_for(:click)[0], 
      Apotomo::InvokeEventHandler.new(:widget_id => 'my_widget', :state => 'processClick')
    
    
    w.respond_to_event :click, :with => :processClick, :on => 'some_target'
    assert_equal 2, t.size
    assert_equal t.handlers_for(:click)[1], 
      Apotomo::InvokeEventHandler.new(:widget_id => 'some_target', :state => 'processClick')
    
    
    w.respond_to_event :click, :with => :react, :on => 'moving_target', :from => 'some_source'
    assert_equal 3, t.size
    assert_equal t.handlers_for(:click, 'some_source')[0], 
      Apotomo::InvokeEventHandler.new(:widget_id => 'moving_target', :state => 'react')
  end
  
  
  def test_respond_to_event_with_multiple_attaches
    w = cell(:rendering_test, :widget_content, 'my_widget')
    t = w.evt_table
    
    assert_equal(0, t.size)
    
    
    w.respond_to_event :click, :with => :processClick, :again => true
    assert_equal 1, t.size
    assert_equal t.handlers_for(:click)[0], 
      Apotomo::InvokeEventHandler.new(:widget_id => 'my_widget', :state => 'processClick')
    
    
    w.respond_to_event :click, :with => :processClick, :again => true
    assert_equal 2, t.size
    assert_equal t.handlers_for(:click)[1], t.handlers_for(:click)[0]
  end
  
  
end