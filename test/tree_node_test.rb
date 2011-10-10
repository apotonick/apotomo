require 'test_helper'

class TreeNodeTest < ActiveSupport::TestCase
  context "initialization" do
    setup do
      
    end
    
    should "return true for #root? without parent" do
      assert MouseWidget.new(nil, :mum).root?
    end
    
    should "return false for #root? with parent" do
      @mum = MouseWidget.new(nil, :mum)
      assert_not MouseWidget.new(@mum, :kid).root?
    end
    
  end
end
