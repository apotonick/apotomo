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



class EventTableTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def setup
    super
    @processor = Apotomo::EventProcessor.instance.init!
  end
  
  
  def test_event_table
    tbl = Apotomo::EventTable.new
    assert_kind_of Apotomo::EventTable, tbl
  end
  
  def test_size
    t = Apotomo::EventTable.new
    assert_equal 0, t.size
    
    h = Apotomo::EventHandler.new
    t.add_handler(h, :event_type => :event1, :source_id => :observed_widget_id1)
    t.add_handler(h, :event_type => :event2, :source_id => :observed_widget_id2)
    
    assert_equal 2, t.size
  end
  
  def test_add_handler_once
    t = Apotomo::EventTable.new
    
    h = Apotomo::EventHandler.new
    
    t.add_handler_once h, :source_id => :id, :event_type => :someEvent
    t.add_handler_once h, :source_id => :id, :event_type => :someEvent
    
    assert_equal 1, t.size
    assert_equal h, t.handlers_for(:someEvent, :id)
  end
  
  
  def test_add_handler
    t = Apotomo::EventTable.new
    
    h1 = Apotomo::EventHandler.new
    h2 = Apotomo::EventHandler.new
    h3 = Apotomo::EventHandler.new
    
    ### TODO: implement a catch-all:
    #t.add_handler h
    
    t.add_handler h1, :source_id => :id, :event_type => :idEvent
    t.add_handler h2, :source_id => :ia, :event_type => :someEvent
    t.add_handler h1, :source_id => :ia, :event_type => :someEvent
    t.add_handler h3, :event_type => :someEvent
    
    
    assert_equal [],            t.handlers_for(:someEvent,  :id)
    assert_equal [h1],          t.handlers_for(:idEvent,    :id)
    assert_equal [h2, h1],      t.handlers_for(:someEvent,  :ia)  # order matters.
    assert_equal [h3],          t.handlers_for(:someEvent)
    
    assert_equal [h3],          t.all_handlers_for(:someEvent,  :id)
    assert_equal [h1],          t.all_handlers_for(:idEvent,    :id)
    assert_equal [h2,h1,h3],    t.all_handlers_for(:someEvent,  :ia)
  end
  
  
  ### TODO: move to test_triggering/test_event_processor.
  def test_handler_queueing_when_triggered_in_cell_state
    m = mouse_mock('mommy')
      m << s= mouse_mock('sender', :fire_event) do
        def fire_event
          trigger :click 
          render :nothing => true
        end
      end
      
      m << r= mouse_mock('receiver', :receive_event) do
        def receive_event; render :text => "gotcha!"; end
      end
    m.respond_to_event :click, :on => 'receiver', :with => :receive_event
    
    s.invoke  # trigger :click
    
    assert_equal 1, @processor.queue.size
    a = @processor.queue.first
    # test [handler, event]:
    assert_equal "InvokeEventHandler:receiver#receive_event", a.first.to_s
    assert_equal s.name, a.last.source.name
  end
  
end
