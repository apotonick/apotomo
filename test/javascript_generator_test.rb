require 'test_helper'

class JavascriptGeneratorTest < MiniTest::Spec
  describe "The JavascriptGenerator" do
    it "raise an error if no framework passed" do
      assert_raises RuntimeError do
        Apotomo::JavascriptGenerator.new(nil)
      end
    end

    describe "in prototype mode" do
      before do
        @gen = Apotomo::JavascriptGenerator.new(:prototype)
      end

      it "respond to prototype" do
        assert_respond_to @gen, :prototype
      end

      it "respond to replace" do
        assert_equal "jQuery(\"drinks\").replace(\"EMPTY!\");", @gen.replace(:drinks, 'EMPTY!')
      end

      it "respond to replace_id" do
        assert_equal "jQuery(\"drinks\").replace(\"EMPTY!\");", @gen.replace_id("drinks", 'EMPTY!')
      end

      it "respond to update" do
        assert_equal "jQuery(\"drinks\").update(\"<li id=\\\"beer\\\"><\\/li>\");", @gen.update(:drinks, '<li id="beer"></li>')
      end

      it "respond to update_id" do
        assert_equal "jQuery(\"drinks\").update(\"EMPTY!\");", @gen.update_id("drinks", 'EMPTY!')
      end
    end

    describe "in right mode" do
      before do
        @gen = Apotomo::JavascriptGenerator.new(:right)
      end

      it "respond to right" do
        assert_respond_to @gen, :right
      end

      it "respond to replace" do
        assert_equal "jQuery(\"drinks\").replace(\"EMPTY!\");", @gen.replace(:drinks, 'EMPTY!')
      end

      it "respond to replace_id" do
        assert_equal "jQuery(\"drinks\").replace(\"EMPTY!\");", @gen.replace_id("drinks", 'EMPTY!')
      end

      it "respond to update" do
        assert_equal "jQuery(\"drinks\").update(\"<li id=\\\"beer\\\"><\\/li>\");", @gen.update(:drinks, '<li id="beer"></li>')
      end

      it "respond to update_id" do
        assert_equal "jQuery(\"drinks\").update(\"EMPTY!\");", @gen.update_id("drinks", 'EMPTY!')
      end
    end

    describe "in jQuery mode" do
      before do
        @gen = Apotomo::JavascriptGenerator.new(:Jquery)
      end

      it "respond to jQuery" do
        assert_respond_to @gen, :jquery
      end

      it "respond to replace" do
        assert_equal "jQuery(\"#drinks\").replaceWith(\"EMPTY!\");", @gen.replace("#drinks", 'EMPTY!')
      end

      it "respond to replace_id" do
        assert_equal "jQuery(\"#drinks\").replaceWith(\"EMPTY!\");", @gen.replace_id("drinks", 'EMPTY!')
      end

      it "respond to update" do
        assert_equal "jQuery(\"#drinks\").html(\"<li id=\\\"beer\\\"><\\/li>\");", @gen.update("#drinks", '<li id="beer"></li>')
      end

      it "respond to update_id" do
        assert_equal "jQuery(\"#drinks\").html(\"EMPTY!\");", @gen.update_id("drinks", 'EMPTY!')
      end
    end
  end
end
