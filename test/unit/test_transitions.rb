require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class TransitionsDefinedInInstance
  include Apotomo::Transitions
  
  attr_accessor :start_states
  
  def initialize
    @start_states = [:start_state_1, :start_state_2]
  end
  
  def transition_map
    {:start_state_2 => [:state_2_1, :state_2_2, :start_state_2],
      :state_2_2 => [:state_2_2, :start_state_2] }
  end
end

class TransitionsDefinedInClass
  include Apotomo::Transitions
  extend Apotomo::Transitions::ClassMethods
  transition( :from => :one, :to => :two)
  transition :in => :two
  transition :from => :two, :to => :one
end

class TransitionsDefinedInBoth
  include Apotomo::Transitions
  transition :from => :one, :to => :two
  transition :in => :two
  transition :from => :two, :to => :one
  
  def transition_map
    { :two => [:three],
      :three => [:four],
    }
  end
end
  

class TransistionsTest < Test::Unit::TestCase
  def setup
    @t = TransitionsDefinedInInstance.new
    @c = TransitionsDefinedInClass.new
    @b = TransitionsDefinedInBoth.new
  end
  
  def test_transitions
    # only transition_map defined
    assert_equal @t.find_next_state_for(:start_state_2, :start_state_2_1), :state_2_1
    
    # only transition defined
    assert_equal @c.find_next_state_for(:one, :two), :two
    assert_equal @c.find_next_state_for(:one, :three), :two
    assert_equal @c.find_next_state_for(:two, :two), :two
    
    # both
    assert_equal @b.find_next_state_for(:one, :two), :two       # defined in class
    assert_equal @b.find_next_state_for(:one, :three), :two     # not defined
    
    assert_equal @b.find_next_state_for(:three, :four), :four   # defined in instance
    
    
    # both, transition_map taking precedence
    assert_equal @b.find_next_state_for(:two, :one), :three     # in class, overwritten in instance
    assert_equal @b.find_next_state_for(:two, :two), :three     # in class, overwritten in instance
    
  end
  
  def test_is_start_state
    assert @t.start_state?(:start_state_1)
    assert ! @t.start_state?(:start_state_3)
    
  end
  
  def test_default_start_state
    assert_equal @t.default_start_state, :start_state_1
  end
  
  def test_find_next_state_for_without_last_state
    assert_equal @t.find_next_state_for(nil, :start_state_1), :start_state_1
    assert_equal @t.find_next_state_for(nil, :start_state_2), :start_state_2
    assert_equal @t.find_next_state_for(nil, :NO_start_state), :start_state_1
    assert_equal @t.find_next_state_for(nil, nil), :start_state_1
    assert_equal @t.find_next_state_for(nil, "*"), :start_state_1
    assert_equal @t.find_next_state_for(nil, "_"), :start_state_1
  end
  
  def test_find_next_state_for_with_last_state
    assert_equal @t.find_next_state_for(:start_state_1, :start_state_1), :start_state_1
    assert_equal @t.find_next_state_for(:start_state_1, :start_state_2), :start_state_1
    assert_equal @t.find_next_state_for(:start_state_1, nil), :start_state_1
    assert_equal @t.find_next_state_for(:start_state_2, nil), :state_2_1
  end
  
  def test_default_next_state_for
    assert_equal @t.default_next_state_for(:start_state_1), nil
    assert_equal @t.default_next_state_for(:NO_STATE), nil
    assert_equal @t.default_next_state_for(nil), nil
    assert_equal @t.default_next_state_for(:start_state_2), :state_2_1
  end
  
  def test_start_state_for_state
    assert_equal @t.start_state_for_state(:state_2_2), :start_state_2
    assert_equal @t.start_state_for_state(:NO_STATE), :start_state_1
  end
  
end
