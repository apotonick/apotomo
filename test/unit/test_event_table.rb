require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class TestWidget < Apotomo::StatefulWidget
  def test_state; end;
  def another_state; end;
  def another_state2; end;
  
  def fireing_state
    trigger(:click)
  end
  
  def fireman_state
    "fireman invoked!"
  end
end

# fixture:
class ApplicationWidgetTree < Apotomo::WidgetTree
  
  def draw(root)
    root.watch(:onWidget, :widget_one, :widget_two, :some_state)
    
    root << widget('test_widget', :test_widget_id)
    root << widget('test_widget', :target_widget_id)
    root << widget('test_widget', :target2_widget_id)
    root << widget('test_widget', :widget_one)
    root << widget('test_widget', :widget_two)
    root << widget('test_widget', :widget_three)
    root
    
    root << widget('test_widget', :fireing, :fireing_state)
    root << widget('test_widget', :fireman, :fireman_state)
    root.watch(:click, :fireman, :fireman_state, :fireing)
  end
end



class EventTableTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def setup
    super
    processor = Apotomo::EventProcessor.instance
    processor.init
  end
  
  
  def tree
    ApplicationWidgetTree.new(@controller).draw_tree.root
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
    assert_kind_of Apotomo::EventHandler, evt_handler
    assert_equal evt_handler.widget_id, :target_widget_id
    assert_equal evt_handler.state, :another_state
    
    evt_handler = events[1]
    assert_kind_of Apotomo::EventHandler, evt_handler
    assert_equal evt_handler.widget_id, :target2_widget_id
    assert_equal evt_handler.state, :another_state2
  end
  
  def test_processing_with_one_handler
    tbl = Apotomo::EventTable.new    
    tbl.monitor(:onWidget, :observed_widget_id, :target_widget_id, :another_state)
    
    # process Handler directly:
    handler= Apotomo::EventHandler.new
    handler.widget_id = :test_widget_id
    handler.state     = :test_state
    
    processor = Apotomo::EventProcessor.instance
    processor.queue_handler(handler)
    puts tree
    processor.process_queue_for(tree)
    
    processed_handler = processor.processed_handlers[0]
    assert_equal processed_handler.widget_id, handler.widget_id
    assert_equal processed_handler.state, handler.state
  end
  
  def test_processing_with_no_handler
    tbl = Apotomo::EventTable.new    
    
    processor = Apotomo::EventProcessor.instance
    processor.process_handlers_for([], nil)
    assert_equal processor.already_processed.size, 0
  end
  
  def test_processing_with_handler_chain_attached_to_root
    tbl = Apotomo::EventTable.new    
    tbl.monitor(:afterInvoke, :test_widget_id, :target_widget_id, :another_state)
    tbl.monitor(:afterInvoke, :test_widget_id, :target2_widget_id, :another_state2)
    t = tree
    t.root.evt_table = tbl
    
    #puts t.root.evt_table.inspect
    
    # process Handler directly:
    handler= Apotomo::EventHandler.new
    handler.widget_id = :test_widget_id
    handler.state     = :test_state
    
    processor = Apotomo::EventProcessor.instance
    processor.queue_handler(handler)
    processor.process_queue_for(t)
    
    #puts handler.inspect
    #puts processor.processed_handlers.inspect
    assert_equal processor.processed_handlers[0], handler
    assert processor.already_processed["target_widget_id-another_state"]
    assert processor.already_processed["target2_widget_id-another_state2"]
  end
  
  def test_processing_with_handler_chain_and_loop
    tbl = Apotomo::EventTable.new
    # define an observer loop:
    tbl.monitor(:afterInvoke, :test_widget_id, :target_widget_id, :another_state)
    tbl.monitor(:afterInvoke, :target_widget_id, :test_widget_id, :test_state)
    t = tree
    t.root.evt_table = tbl
    
    
    # process Handler directly:
    handler= Apotomo::EventHandler.new
    handler.widget_id = :test_widget_id
    handler.state     = :test_state
    
    processor = Apotomo::EventProcessor.instance
    processor.queue_handler(handler)
    processor.process_queue_for(t)
    
    processed_handler = processor.processed_handlers[0]
    
    assert_equal processor.already_processed.size, 2
    assert_equal processed_handler.widget_id, handler.widget_id
    assert_equal processed_handler.state, handler.state
    assert processor.already_processed["target_widget_id-another_state"]
  end
  
  
  def test_processing_with_sourceless_listener
    tbl = Apotomo::EventTable.new    
    tbl.monitor(:someEvent, nil, :target_widget_id, :another_state)
    
    hs = tbl.event_handlers_for(:someEvent, :unknown_widget)
    assert_equal 1, hs.size
  end
  
  
  ### TODO: this test is weak.
  def test_observer_in_model_tree
    tree = ApplicationWidgetTree.new(@controller).draw_tree
    assert tree.root.evt_table.source2evt.size > 0
  end
  
  
  def test_triggering_in_cell_state
    t = ApplicationWidgetTree.new(@controller).draw_tree.root
    f = t.find_by_id(:fireing)
    f.render_content  # trigger :click
    
    evt_processor = Apotomo::EventProcessor.instance
    
    assert_equal evt_processor.queue.size, 1
    #f.evt_table.already_process
  end
  
end
