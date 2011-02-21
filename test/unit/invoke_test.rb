require 'test_helper'

class InvokeTest < Test::Unit::TestCase
  include Apotomo::TestCaseMethods::TestController
  
  context "Invoking a single widget" do
    setup do
      @mum = mouse_mock('mum', :eating)
    end
    
    context "#invoke_state" do
      should "accept a state, only" do
        @mum.invoke_state :eating
        assert_equal 'eating', @mum.last_state
      end
      
      should "pass args as state-args" do
        @mum.instance_eval do
          def snuggle(duration)
            @duration = duration
          end
        end
        @mum.invoke_state :snuggle, "forever"
        assert_equal 'snuggle', @mum.last_state
        assert_equal "forever", @mum.instance_variable_get(:@duration)
      end
    end
    
    context "explicitely" do
      should "always enter the given state" do
        @mum.invoke :eating
        assert_equal 'eating', @mum.last_state
        
        @mum.invoke :eating
        assert_equal 'eating', @mum.last_state
      end
    end
    
    context "implicitely" do
      should "per default enter the start state" do
        @mum.invoke
        assert_equal 'eating', @mum.last_state
        
        @mum.invoke
        assert_equal 'eating', @mum.last_state
      end
      
      context "with defined transitions" do
        setup do
          @mum.instance_eval do
            self.class.transition :from => :eating, :to => :squeak
          end
          
          @mum.invoke
          assert_equal 'eating', @mum.last_state
        end
        
        should "automatically follow the transitions if defined" do
          assert_equal 'eating', @mum.last_state
          @mum.invoke
          assert_equal 'squeak', @mum.last_state
        end
        
        should "nevertheless allow undefined explicit invokes" do
          @mum.invoke :eating
          assert_equal 'eating', @mum.last_state
        end
      end
    end
  end
end
