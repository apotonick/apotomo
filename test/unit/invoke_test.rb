require 'test_helper'

class InvokeTest < Test::Unit::TestCase
  include Apotomo::TestCaseMethods::TestController
  
  context "#invoke" do
    setup do
      @mum = mouse_mock('mum', :eating)
    end
    
    should "accept a state, only" do
      @mum.invoke(:eating)
      assert_equal 'eating', @mum.last_state
    end
      
    should "pass args as state-args" do
      @mum.instance_eval do
        def snuggle(duration)
          @duration = duration
        end
      end
      @mum.invoke :snuggle, "forever"
      assert_equal 'snuggle', @mum.last_state
      assert_equal "forever", @mum.instance_variable_get(:@duration)
    end
  end
end
