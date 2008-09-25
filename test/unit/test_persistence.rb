require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class PersistenceTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def test_dump
    t = cell(:my_test, :widget_content, 'my_id')
    t.last_state = :test_state
    
    puts d = Marshal::dump(t)
    
    t = Marshal::load(d)
    t.controller = controller
    assert_kind_of Apotomo::StatefulWidget, t
    assert_equal t.last_state, :test_state
    puts t.invoke
  end
  
  def test_cycle_with_two
    t = cell(:my_test, :widget_content, 'my_id')
    t << t2 = cell(:my_test, :widget_content, 'my_id_2')
    t.last_state = :test_state
    t2.last_state = :test_state2
    
    puts d = Marshal::dump(t)
    
    
    t = Marshal::load(d)
    ### FIXME: only connect once:
    t.controller = controller
    t.children.first.controller = controller
    
    assert_kind_of Apotomo::StatefulWidget, t
    assert_equal t.last_state, :test_state
    assert_kind_of MyTestCell, t.children.first
    assert_equal t.children.first.last_state, :test_state2
    
    puts t.invoke
    
  end
  
  
end

class MyTestCell < Apotomo::StatefulWidget
end
