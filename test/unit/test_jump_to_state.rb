require 'test_helper'

### DISCUSS: move some tests from PersistenceTest to this test file.


class InterStateTest < ActionController::TestCase
  include Apotomo::UnitTestCase  
  
  # do we really jump to the correct state?
  # and: are all state ivars remembered while jumping?
  def test_three_state_jumps
    w = StateJumpCell.new('x', :one)
    w.controller = @controller
    
    c = w.invoke  # :one -> :two -> :three
    
    assert_state w, :three
    puts "brain dump:"
    puts w.brain.inspect
    
    assert w.brain.include?("@var")
    assert w.brain.include?("@one");
    assert_equal "three,one", c
  end
  
  
  def test_brain_reset_when_invoking_a_start_state
    w = StateJumpCell.new('x', :counter)
    w.controller = @controller
    
    assert_equal "1", w.invoke
    # another #invoke will flush brain:
    assert_equal "1", w.invoke
  end
  
  def test_brain_reset_when_jumping_to_a_start_state
    w = StateJumpCell.new('x', :counter)
    w.controller = @controller
    w.instance_eval do
      def back_to_start
        jump_to_state :counter  # :counter is a start state.
      end
    end
    
    assert_equal "1", w.invoke
    # if using #jump_to_state there should be NO brain flush:
    assert_equal "2", w.invoke_state(:back_to_start)
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
    jump_to_state :two
  end
  
  def two
    @var = "two"
    jump_to_state :three
  end
  
  def three
    @var = "three"
    render :text => "#{@var},#{@one}"
  end
  
  def four
    render :text => ""
  end
  
  def counter
    @counter ||= 0
    @counter += 1
    render :text => @counter.to_s
  end
  
end
