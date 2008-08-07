require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class MyTransitions
  include Apotomo::Transitions
  
  attr_accessor :start_states
  
  def initialize
    @start_states = [:start_state_1, :start_state_2]
  end
  
  def transitions
    {:start_state_2 => [:state_2_1, :state_2_2, :start_state_2],
      :state_2_2 => [:state_2_2, :start_state_2] }
  end
end


class TransistionsTest < Test::Unit::TestCase
  def setup
    @t = MyTransitions.new
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
