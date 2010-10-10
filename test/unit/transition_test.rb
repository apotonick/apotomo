require 'test_helper'

class TransitionTest < Test::Unit::TestCase
  context "Calling #next_state_for" do
    setup do
      @mum = Object.new
      @mum.class.instance_eval do
          include Apotomo::Transition
      end
    end
    
    should "return nil when no transition is defined" do
      assert_not @mum.send(:next_state_for, :snuggle)
    end
    
    should "return the defined next state" do
      @mum.class.instance_eval do
        transition :from => :snuggle, :to => :sleep
      end
      
      assert_equal :sleep, @mum.send(:next_state_for, :snuggle)
      assert_equal :sleep, @mum.send(:next_state_for, "snuggle")
    end
    
    should "return the state that was defined last" do
      @mum.class.instance_eval do
        transition :from => :snuggle, :to => :sleep
        transition :from => :snuggle, :to => :snore
      end
      
      assert_equal :snore, @mum.send(:next_state_for, :snuggle)
    end
  end
end
