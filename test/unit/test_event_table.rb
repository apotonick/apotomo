require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class TestWidget < Apotomo::StatefulWidget
  def test_state; end;
  def another_state; end;
  def another_state2; end;
  
  def fireing_state
    trigger(:click)
    ""
  end
  
  def fireman_state
    "fireman invoked!"
  end
end

# fixture:
class EventTableWidgetTree < Apotomo::WidgetTree
  
  def draw(root)
    root.watch(:onWidget, :widget_one, :widget_two, :some_state)
    
    root << widget('test_widget', :widget_content, :test_widget_id)
    root << widget('test_widget', :widget_content, :target_widget_id)
    root << widget('test_widget', :widget_content, :target2_widget_id)
    root << widget('test_widget', :widget_content, :widget_one)
    root << widget('test_widget', :widget_content, :widget_two)
    root << widget('test_widget', :widget_content, :widget_three)
    root
    
    root << widget('test_widget', :fireing_state, :fireing)
    root << widget('test_widget', :fireman_state, :fireman)
    root.watch(:click, :fireman, :fireman_state, :fireing)
  end
end



class EventTableTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def setup
    super
    @processor = Apotomo::EventProcessor.instance.init!
  end
  
  
  def tree
    r = apotomo_root_mock
    EventTableWidgetTree.new.draw(r)
    r
  end
  
  
  def test_event_table
    tbl = Apotomo::EventTable.new
    assert_kind_of Apotomo::EventTable, tbl
  end
  
  def test_register_listener
    tbl = Apotomo::EventTable.new
    
    tbl.monitor(:onWidget, :observed_widget_id, :target_widget_id, :another_state)
    #tbl.register_listener()
    events = tbl.event_handlers_for(:onWidget, :observed_widget_id)
    assert_kind_of Array, events
    assert_equal events.size, 1
    
    evt_handler = events.first
    assert_kind_of Apotomo::EventHandler, evt_handler
    assert_equal evt_handler.widget_id, :target_widget_id
    assert_equal evt_handler.state, :another_state
  end
  
  def test_register_listener_with_two_handlers
    tbl = Apotomo::EventTable.new
    
    tbl.monitor(:onWidget, :observed_widget_id, :target_widget_id, :another_state)
    tbl.monitor(:onWidget, :observed_widget_id, :target2_widget_id, :another_state2)
    
    #puts tbl.source2evt.inspect
    
    events = tbl.event_handlers_for(:onWidget, :observed_widget_id)
    assert_kind_of Array, events
    assert_equal events.size, 2
    
    evt_handler = events[0]
    assert_kind_of Apotomo::InvokeEventHandler, evt_handler
    assert_equal evt_handler.widget_id, :target_widget_id
    assert_equal evt_handler.state, :another_state
    
    evt_handler = events[1]
    assert_kind_of Apotomo::InvokeEventHandler, evt_handler
    assert_equal evt_handler.widget_id, :target2_widget_id
    assert_equal evt_handler.state, :another_state2
  end
  
  
  
  def test_processing_with_sourceless_listener
    tbl = Apotomo::EventTable.new    
    tbl.monitor(:someEvent, nil, :target_widget_id, :another_state)
    
    hs = tbl.event_handlers_for(:someEvent, :unknown_widget)
    assert_equal 1, hs.size
  end
  
  
  ### TODO: this test is weak.
  def test_observer_in_model_tree
    assert tree.root.evt_table.source2evt.size > 0
  end
  
  
  ### TODO: move to test_triggering/test_event_processor.
  def test_handler_queueing_when_triggered_in_cell_state
    f = tree.find_by_id(:fireing)
    f.invoke  # trigger :click
    
    assert_equal 1, @processor.queue.size
    a = @processor.queue.first
    # test [handler, event]:
    assert_equal "InvokeEventHandler:fireman#fireman_state", a.first.to_s
    assert_equal f, a.last.source
  end
  
end
