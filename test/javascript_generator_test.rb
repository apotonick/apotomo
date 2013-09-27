require 'test_helper'

class JavascriptGeneratorTest < MiniTest::Spec
  describe "The JavascriptGenerator" do
    describe "constructor" do
      it "accept framework name and return an correct instance" do
        @gen = Apotomo::JavascriptGenerator.new(:Jquery)

        assert_kind_of Apotomo::JavascriptGenerator, @gen
        assert_kind_of Apotomo::JavascriptGenerator::Jquery, @gen
      end

      it "raise an error if no framework passed" do
        assert_raises RuntimeError do
          Apotomo::JavascriptGenerator.new(nil)
        end
      end
    end

    it "respond to ::escape" do
      assert_equal '', Apotomo::JavascriptGenerator.escape(nil)
      assert_equal %(This \\"thing\\" is really\\n netos\\'), Apotomo::JavascriptGenerator.escape(%(This "thing" is really\n netos'))
      assert_equal %(backslash\\\\test), Apotomo::JavascriptGenerator.escape(%(backslash\\test))
      assert_equal %(dont <\\/close> tags), Apotomo::JavascriptGenerator.escape(%(dont </close> tags))
    end

    describe "in jQuery mode" do
      before do
        @gen = Apotomo::JavascriptGenerator.new(:Jquery)
      end

      it "respond to #escape" do
        assert_equal '', @gen.escape(nil)
        assert_equal %(This \\"thing\\" is really\\n netos\\'), @gen.escape(%(This "thing" is really\n netos'))
        assert_equal %(backslash\\\\test), @gen.escape(%(backslash\\test))
        assert_equal %(dont <\\/close> tags), @gen.escape(%(dont </close> tags))
      end

      it "respond to #<< and return argument converted to String" do
        assert_equal "bla_bla", (@gen << "bla_bla")
        assert_equal "bla_bla", (@gen << :bla_bla)
      end

      it "respond to #jquery" do
        assert_respond_to @gen, :jquery
      end

      it "respond to #element" do
        assert_equal "jQuery(\"#drinks\")", @gen.element("#drinks")
      end

      it "respond to #replace" do
        assert_equal "jQuery(\"#drinks\").replaceWith(\"EMPTY!\");", @gen.replace("#drinks", 'EMPTY!')
      end

      it "respond to #replace_id" do
        assert_equal "jQuery(\"#drinks\").replaceWith(\"EMPTY!\");", @gen.replace_id("drinks", 'EMPTY!')
      end

      it "respond to #update" do
        assert_equal "jQuery(\"#drinks\").html(\"<li id=\\\"beer\\\"><\\/li>\");", @gen.update("#drinks", '<li id="beer"></li>')
      end

      it "respond to #update_id" do
        assert_equal "jQuery(\"#drinks\").html(\"EMPTY!\");", @gen.update_id("drinks", 'EMPTY!')
      end

      # TODO: Prototype mode

      # TODO: Right mode

    end
  end
end
