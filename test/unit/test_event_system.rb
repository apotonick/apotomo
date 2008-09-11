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
  end
  
  def fireman_state
    "fireman invoked!"
  end
end


class ApplicationWidgetTree < Apotomo::WidgetTree
  
  
end



class EventSystemTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def test_single_widget_rendering
    w = widget(:test_widget, 'root', :simple_state)
    evt = Apotomo::Event.new(:invoke, w.name, {:state => :simple_state})
      
    puts w.invoke_for_event(evt)
    
    assert_state w, :simple_state
    assert_event :invoke, 'root'
  end
  
  def test_widget_firing_event
    w1  = widget(:test_widget, 'w1', :fireing_state)
    w2  = widget(:test_widget, 'w2', :simple_state)
    w3  = widget(:test_widget, 'w3', :following_state)
    
    w1 << w2
    w1 << w3
    w1.watch(:click, 'w2', :simple_state)
    w1.watch(:no_click, 'w2', :simple_state)
    w1.watch(:click, 'w3', :simple_state)
    
    evt = Apotomo::Event.new(:invoke, w1.name, {:state => :simple_state})      
    w1.invoke_for_event(evt)
    
    assert_state w1, :fireing_state
    assert_state w2, :simple_state
    assert_state w3, :following_state
    assert_event :invoke, 'w1'
    assert_event :click, 'w1'
    assert_equal 3, Apotomo::EventProcessor.instance.processed_handlers.size
    puts Apotomo::EventProcessor.instance.processed_handlers
  end
  
  
  def fixture_widgets
    root = widget(:test_widget, 'root', :simple_state)
    
    root << widget(:test_widget, '')
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
