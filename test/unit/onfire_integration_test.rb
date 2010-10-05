require 'test_helper'
 
class OnfireIntegrationTest < Test::Unit::TestCase
  context "including Onfire into the StatefulWidget it" do
    setup do
      @mum = mouse_mock('mum')
      @mum << @kid = mouse_mock('kid')
    end
    
    should "respond to #root" do
      assert @mum.root?
      assert ! @kid.root?
    end
    
    should "respond to #parent" do
      assert_equal @mum, @kid.parent
    end
  end
end
