require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class EventProcessorTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def test_process_queue
    p = Apotomo::EventProcessor.instance.init!
    
    h = Apotomo::InvokeEventHandler.new
    h.widget_id = 'mouse'
    h.state     = :eating
    
    h2 = Apotomo::InvokeEventHandler.new
    h2.widget_id = 'mouse'
    h2.state     = :feeding
    
    # queue handlers, this usually happens in #peek and #trigger:
    e = Apotomo::Event.new
    e.source = mouse_mock
    
    p.queue_handler_with_event h, e
    
    p.queue_handler_with_event h2, e
    processed = p.process_queue
    
    assert_equal 2,   processed.size
    assert_equal h,   processed.first.first
    assert_equal h2,  processed.second.first
  end
  
  def test_process_queue_with_handler_loop
    p = Apotomo::EventProcessor.instance.init!
    
    h = Apotomo::InvokeEventHandler.new
    h.widget_id = 'mouse'
    h.state     = :eating
    
    h2 = Apotomo::InvokeEventHandler.new
    h2.widget_id = 'mouse'
    h2.state     = :feeding
    
    # queue handlers, this usually happens in #peek and #fire:
    e = Apotomo::Event.new
    e.source = mouse_mock
    
    p.queue_handlers_with_event [h, h2, h], e
    processed = p.process_queue
    
    #assert_equal 2,   processed.size
    assert_equal 3,   processed.size
    (handler, c) = processed.first
    assert_equal h,   handler
    (handler, c) = processed.second
    assert_equal h2,  handler
  end
  
  
end
