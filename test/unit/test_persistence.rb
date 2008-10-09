require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class PersistenceTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  def test_dump
    t = cell(:my_test, :widget_content, 'my_id')
    
    d = Marshal::dump(t)
    t = Marshal::load(d)
    
    assert_kind_of Apotomo::StatefulWidget, t
  end
  

  
  def test_instance_variable_referencing_between_different_widgets
    m = cell(:master, :set_shared, 'master')
      s = m << cell(:slave, :read_shared, 'slave')
    
    m.invoke
    
    assert_equal m.my_shared.value, "first value"
    assert_state m, :set_shared
    assert_equal s.my_shared.value, "first value"
    assert_state s, :read_shared
    
    
    freeze_tree_for(m, session)
    puts " --------- new request ---------"
    m = thaw_tree_for(session, controller)
    
    
    m.invoke(:reset_shared)
    
    s = m.find_by_id('slave')
    
    assert_equal m.my_shared.value, "second value"
    assert_state m, :reset_shared
    assert_equal s.my_shared.value, "second value"
    assert_state s, :read_shared
  end
  
  
  include Apotomo::ControllerHelper ### TODO: move to UnitTest helper.
  # tests if variable referencing is frozen/thawed correctly, especially if
  # some widget instance var points to a var in session and another widget 
  # updates it, they should both still point to the same object.
  def test_session_variable_referencing
    m = cell(:master, :set_shared_in_session, 'master')
      s = m << cell(:slave, :read_shared, 'slave')
    
    m.invoke
    
    assert_equal m.param(:shared).value, "value from session"
    assert_state m, :set_shared_in_session
    assert_equal s.my_shared.value, "value from session"
    assert_state s, :read_shared
    
    freeze_tree_for(m, session)
    puts " --------- new request ---------"
    m = thaw_tree_for(session, controller)
    
    
    s = m.find_by_id('slave')
    s.invoke(:set_shared)
    
    
    
    assert_equal m.param(:shared).value, "value from child"
    assert_state m, :set_shared_in_session
    assert_equal s.my_shared.value, "value from child"
    assert_state s, :set_shared
    assert_equal "value from child", controller.session['my_shared'].value    
  end
  
  
  # test if each widget has it's own namespaced session container:
  def test_widget_session_encapsulation
    r = cell(:my_test, :some, 'root')
      r << a= cell(:my_test, :some, 'a')
      r << b1= cell(:my_test, :some, 'b')
        a << b2= cell(:my_test, :some, 'b')
    
    freeze_tree_for(r, session)
    
    assert_equal session['apotomo_widget_content'].size, 4
  end
  
  # test if removed widgets are removed from the session container:
  def test_widget_session_cleanup
    r = cell(:my_test, :some, 'root')
      r << a= cell(:my_test, :some, 'a')
      r << b1= cell(:my_test, :some, 'b')
        a << b2= cell(:my_test, :some, 'b')
    
    
    freeze_tree_for(r, session)
    
    r = thaw_tree_for(session, controller)
    r.find_by_id('b').removeFromParent!
    
    freeze_tree_for(r, session)
    assert_equal session['apotomo_widget_content'].size, 3
    #assert session['apotomo_widget_content'].reject?('b')
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
