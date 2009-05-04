require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class PersistenceTest < ActionController::TestCase
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
    
    
    m = hibernate_widget(m)
    
    
    m.invoke(:reset_shared)
    
    s = m.find_by_id('slave')
    puts s
    assert_equal m.my_shared.value, "second value"
    assert_state m, :reset_shared
    assert_equal s.my_shared.value, "second value"
    assert_state s, :read_shared
  end
  
  
  include Apotomo::ControllerMethods ### TODO: move to UnitTest helper.
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
    
    m = hibernate_widget(m)
    puts " --------- new request ---------"
    
    
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
    
    hibernate_widget(r)
    
    assert_equal session['apotomo_widget_content'].size, 4
  end
  
  # test if removed widgets are removed from the session container:
  def test_widget_session_cleanup
    r = cell(:my_test, :some, 'root')
      r << a= cell(:my_test, :some, 'a')
      r << b1= cell(:my_test, :some, 'b')
        a << b2= cell(:my_test, :some, 'b')
    
    
    r = hibernate_widget(r)
    
    r.find_by_id('b').removeFromParent!
    
    hibernate_widget(r)
    assert_equal session['apotomo_widget_content'].size, 3
    #assert session['apotomo_widget_content'].reject?('b')
  end
  
  def test_widget_start_state_cleanup
    r = cell(:my_test, :start, 'root')
    # :start will set a state variable.
    r.invoke
    assert_state r, :start
    assert_equal "value", r.ivar
    
    # if going to a start state, there shouldn't be anything left in the widget.
    r.instance_eval { def start; ""; end; }
    r.invoke
    assert_state r, :start
    assert_equal nil, r.ivar
  end
  
  # @brain should contain all ivars set during successive state executions.
  def test_brain
    r = cell(:my_test, :start, 'root')
    # :start will set a state variable.
    r.invoke
    assert_state r, :start
    assert_equal "value", r.ivar
    assert_equal ['@ivar'], r.brain
    
    # next, go to :one and set another state variable.
    r.invoke :one
    assert_state r, :one
    assert_equal "value", r.ivar
    assert_equal "1",     r.one
    assert_equal ['@ivar', '@one'], r.brain
    
    # and go back to the start state, flushing the brain and starting over:
    r.invoke
    assert_state r, :start
    assert_equal "value", r.ivar
    assert_equal ['@ivar'], r.brain
  end
  
    
  # @state_view, @rendered_children shouldn't be remembered after state rendering.
  def test_reset_rendering_ivars
    r = cell(:my_test, :set_state_view, 'a')
    
    # render state that sets an explicit @state_view:
    r.invoke
    assert_state r, :set_state_view
    assert_equal :widget_content, r.state_view
    
    # go to a state that doesn't set @state_view, which should also be empty now:
    r.invoke :one
    assert_state r, :one
    assert r.state_view.blank?
    assert r.rendered_children.blank?
    
    
    # set state_view, jump to :next state, and render :next view, not the old one:
    r = cell(:rendering_test, :set_state_view_and_jump, 'b')
    c = r.invoke  # state_view! => jump_to_state => :check_state
    assert_state r, :check_state
    assert r.state_view.blank?
    assert_selekt c, "#b", "b is cool."
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
    state_view! :widget_content
  end
  
  def reset_shared
    @my_shared.value = "second value"
    state_view! :widget_content
  end
  
  def set_shared_in_session
    my_shared = SharedObject.new
    my_shared.value = "value from session"
    session['my_shared'] = my_shared
    
    set_local_param(:shared, session['my_shared'])
    state_view! :widget_content
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
  attr_reader :ivar, :one
  # allow testing library ivars from outside:
  attr_reader :brain, :state_view, :rendered_children
  
  transition :in    => :start
  transition :from  => :start, :to => :one
  
  def start
    @ivar = "value"
  end
  
  def one
    @one  = "1"
  end
  
  transition :from => :set_state_view, :to => :one
  def set_state_view
    state_view! :widget_content
  end
end
