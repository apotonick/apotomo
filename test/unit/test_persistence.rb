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
  
  def test_instance_variable_referencing_between_different_widgets
    session = {}
    
    m = cell(:master, :set_shared, 'master')
      s = m << cell(:slave, :read_shared, 'slave')
    
    m.invoke
    
    assert_equal m.my_shared.value, "first value"
    assert_state m, :set_shared
    assert_equal s.my_shared.value, "first value"
    assert_state s, :read_shared
    
    # put widget "structure" into session:
    session['apotomo_widget_tree'] = m
    # put widget instance variables into session:
    session['apotomo_widget_content'] = {}
    m.freeze_instance_vars_to_storage(session['apotomo_widget_content'])
    
    # done by Rails, between requests:
    tmp = Marshal.dump(session)
    session = Marshal.load(tmp)
    puts " --------- new request ---------"
    
    # get widget structure from session:
    m = session['apotomo_widget_tree'].root
    
    # set widget instance variables from session:
    m.thaw_instance_vars_from_storage(session['apotomo_widget_content'])
    
    m.invoke(:reset_shared)
    
    s = m.find_by_id('slave')
    
    assert_equal m.my_shared.value, "second value"
    assert_state m, :reset_shared
    assert_equal s.my_shared.value, "second value"
    assert_state s, :read_shared
  end
  
  def test_session_variable_referencing
    session = {}
    m = cell(:master, :set_shared_in_session, 'master')
      s = m << cell(:slave, :read_shared, 'slave')
    
    m.invoke
    
    assert_equal m.my_shared.value, "value from session"
    assert_state m, :set_shared_in_session
    assert_equal s.my_shared.value, "value from session"
    assert_state s, :read_shared
    
    # put widget "structure" into session:
    session['apotomo_widget_tree'] = m
    # put widget instance variables into session:
    session['apotomo_widget_content'] = {}
    m.freeze_instance_vars_to_storage(session['apotomo_widget_content'])
    
    # done by Rails, between requests:
    tmp = Marshal.dump(session)
    session = Marshal.load(tmp)
    puts " --------- new request ---------"
    
    # get widget structure from session:
    m = session['apotomo_widget_tree'].root
    
    # set widget instance variables from session:
    m.thaw_instance_vars_from_storage(session['apotomo_widget_content'])
    
    s = m.find_by_id('slave')
    s.invoke(:set_shared)
    
    
    assert_equal "value from child", session['my_shared']
    assert_equal m.my_shared.value, "value from child"
    assert_state m, :reset_shared
    assert_equal s.my_shared.value, "value from child"
    assert_state s, :set_shared
  end
  
  
end

class SharedObject
  attr_accessor :value
end

class MasterCell < Apotomo::StatefulWidget
  attr_accessor :my_shared
  
  def transition_map
    {:set_shared => [:reset_shared]}
  end
  
  def set_shared
    @my_shared = SharedObject.new
    @my_shared.value = "first value"
    set_local_param(:shared, @my_shared)
    ""
  end
  
  def reset_shared
    @my_shared.value = "second value"
    ""
  end
  
  def set_shared_in_session
    my_shared = SharedObject.new
    my_shared.value = "value from session"
    session['my_shared'] = my_shared
    
    set_local_param(:shared, session['my_shared'])
    ""
  end
end

class SlaveCell < Apotomo::StatefulWidget
  attr_accessor :my_shared
  
  def transition_map
    {:read_shared => [:read_shared, :set_shared]}
  end
  
  def read_shared
    @my_shared = param(:shared)
    ""
  end
  
  def set_shared
    @my_shared.value = "value from child"
    ""
  end
end

class MyTestCell < Apotomo::StatefulWidget
end
