require File.expand_path(File.dirname(__FILE__) + "/../test_helper")


class InterStateTest < Test::Unit::TestCase
  include Apotomo::UnitTestCase
  
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
end
