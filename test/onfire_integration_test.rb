require 'test_helper'
 
class OnfireIntegrationTest < Test::Unit::TestCase
  include Apotomo::TestCaseMethods::TestController
  
  context "including Onfire into the StatefulWidget it" do
    setup do
      @mum = mouse('mum')
      @mum << mouse_mock(:kid)
      @kid = @mum[:kid]
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
