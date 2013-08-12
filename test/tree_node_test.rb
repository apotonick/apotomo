require 'test_helper'

class TreeNodeTest < MiniTest::Spec
  describe "initialization" do
    it "return true for #root? without parent" do
      assert MouseWidget.new(nil, :mum).root?
    end

    it "return false for #root? with parent" do
      @mum = MouseWidget.new(nil, :mum)
      assert_not MouseWidget.new(@mum, :kid).root?
    end
  end
end
