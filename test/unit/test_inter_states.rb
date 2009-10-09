require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

### DISCUSS: move some tests from PersistenceTest to this test file.


class InterStateTest < ActionController::TestCase
  include Apotomo::UnitTestCase  
  
  # do we really jump to the correct state?
  # and: are all state ivars remembered while jumping?
  def test_three_state_jumps
    w = StateJumpCell.new('x', :one)
    w.controller = @controller
    
    c = w.invoke  # :one -> :_two -> :_three
    
    assert_state w, :_three
    puts "brain dump:"
    puts w.brain.inspect
    
    assert w.brain.include?("@var")
    assert w.brain.include?("@one");
    assert_equal "three,one", c
  end
  
  def test_last_state
    w = StateJumpCell.new('x', :four)
    w.controller = @controller
    c = w.invoke
    assert_equal w.last_state, :four
  end
  
end 


class StateJumpCell < Apotomo::StatefulWidget
  attr_reader :brain
  def one
    @var = "one"
    @one = "one"
    jump_to_state :_two
  end
  
  def _two
    @var = "two"
    jump_to_state :_three
  end
  
  def _three
    @var = "three"
    "#{@var},#{@one}"
  end
  
  def four
    ""
  end
  
end
