require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class InterStateTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
  cattr_accessor :hot_flag
  
  
  def setup
    super
    @controller.session = {}
  end
  
  
  def test_three_state_jumps
    w = StateJumpCell.new(@controller, 'x', :one)
    c = w.invoke  # :one -> :_two -> :_three
    
    assert_equal w.last_state, :_three
    assert_selekt c, "#x", "three"
  end
  
  def test_last_state
    w = StateJumpCell.new(@controller, 'x', :four)
    c = w.invoke
    assert_equal w.last_state, :four
  end
  
  def test_hot?
    self.hot_flag = false
    w = StateJumpCell.new(@controller, 'x', :set_hot)
    assert ! w.hot? # => false
    c = w.invoke
    ### TODO: implement #hot? correct.
    #assert ! w.hot?
    assert self.hot_flag  # => true, we're hot.
  end
  
end 


class StateJumpCell < Apotomo::StatefulWidget
  
  def transition_map
    {
    }
  end
  
  
  def one
    @var = "one"  
    jump_to_state :_two
  end
  
  def _two
    @var = "two"
    jump_to_state :_three
  end
  
  def _three
    @var = "three"
  end
  
  def four
  end
  
  def set_hot
    InterStateTest.hot_flag = hot?
    nil
  end
end
