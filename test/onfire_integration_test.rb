require 'test_helper'

class OnfireIntegrationTest < MiniTest::Spec
  include Apotomo::TestCaseMethods::TestController

  describe "including Onfire into the StatefulWidget it" do
    before do
      @mum = mouse('mum')
      @mum << mouse_mock(:kid)
      @kid = @mum[:kid]
    end

    it "respond to #root" do
      assert @mum.root?
      assert ! @kid.root?
    end

    it "respond to #parent" do
      assert_equal @mum, @kid.parent
    end
  end
end
