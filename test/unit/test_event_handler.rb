require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class EventHandlerTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def test_invoke_to_s
    h = Apotomo::InvokeEventHandler.new
    h.widget_id = :widget_id
    h.state     = :my_state
    assert_equal "InvokeEventHandler:widget_id#my_state", h.to_s
  end
  
  def test_proc_to_s
    h = Apotomo::ProcEventHandler.new
    h.proc = :my_method
    assert_equal "ProcEventHandler:my_method", h.to_s
  end
  
end
