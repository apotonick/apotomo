require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class TestWidget < Apotomo::StatefulWidget
  def transition_map
    { :simple_state => [:following_state],
    }
  end
  def simple_state; "simple!"; end;
  def following_state; "following!"; end;
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

class MyTestWidget < Apotomo::StatefulWidget
  def state_1
    peek :invoke, name, :state_after_peeking
    "state_1"
  end
  
  def state_2
    peek :invoke, name, :state_after_peeking
    "state_2"
  end
  
  def state_with_invoke
    invoke!(:state_1)
    "state_with_invoke"
  end
end

class ApplicationWidgetTree < Apotomo::WidgetTree
  
  
end



class EventSystemTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def setup
    super
    @processor = Apotomo::EventProcessor.instance.init!
  end
  
  def test_single_widget_rendering
    w = widget(:test_widget, :simple_state, 'root')
    w.watch(:invoke, w.name, :simple_state)
    
    evt = Apotomo::Event.new(:invoke, w)
      
    w.invoke_for_event(evt)
    
    assert_state w, :simple_state
    assert_event :invoke, 'root'
  end
  
  def test_widget_firing_event
    w1  = widget(:test_widget, :fireing_state, 'w1')
    w2  = widget(:test_widget, :simple_state, 'w2')
    w3  = widget(:test_widget, :following_state, 'w3')
    
    w1 << w2
    w1 << w3
    w1.watch(:click, 'w2', :simple_state)
    w1.watch(:no_click, 'w2', :simple_state)
    w1.watch(:click, 'w3', :simple_state)
    w1.watch(:invoke, w1.name, :simple_state)
    
    evt = Apotomo::Event.new(:invoke, w1)      
    w1.invoke_for_event(evt)
    
    assert_state w1, :fireing_state
    assert_state w2, :simple_state
    assert_state w3, :following_state
    assert_event :invoke, 'w1'
    assert_event :click, 'w1'
    assert_equal 3, @processor.processed_handlers.size
  end
  
  def test_processed_handlers_resetting
    w1  = widget(:test_widget, :simple_state, 'w1')
    w1.watch(:invoke, w1.name, :simple_state)
    evt = Apotomo::Event.new(:invoke, w1)      
    w1.invoke_for_event(evt)
    assert_equal 1, @processor.processed_handlers.size
    
    # do it again! the processed_handlers queue should be reset.
    evt = Apotomo::Event.new(:invoke, w1, {:state => :simple_state})      
    w1.invoke_for_event(evt)
    assert_equal 1, @processor.processed_handlers.size
  end
  
  
  def test_peek
    w1  = widget(:my_test_widget, [:state_1, :state_2], 'w1')
    w1.invoke(:state_1)
    assert_equal 1, w1.evt_table.handlers_for(:invoke, w1.name).size
    
    w1.invoke(:state_2)
    assert_equal 1, w1.evt_table.handlers_for(:invoke, w1.name).size
  end
  
  def test_invoke!
    w1  = widget(:my_test_widget, [:state_1, :state_2], 'w1')
    w1.invoke!(:state_1)
    
    assert_state w1, :state_1
    assert_equal 1,     Apotomo::EventProcessor.instance.processed_handlers.size
    assert_equal 'w1',  Apotomo::EventProcessor.instance.processed_handlers.first[0]
    assert_equal "state_1", Apotomo::EventProcessor.instance.processed_handlers.first[1]
    
    return
    # test the order in processed_handlers:
    Apotomo::EventProcessor.instance.init!
    w1.invoke!(:state_with_invoke)
    assert_equal 2,     Apotomo::EventProcessor.instance.processed_handlers.size
    assert_equal 'w1',  Apotomo::EventProcessor.instance.processed_handlers.first[0]
    assert_equal "state_1", Apotomo::EventProcessor.instance.processed_handlers.first[1]
    assert_equal 'w1',  Apotomo::EventProcessor.instance.processed_handlers.second[0]
    assert_equal "state_with_invoke", Apotomo::EventProcessor.instance.processed_handlers.second[1]
  end
  
end
