require 'test_helper'

class JavascriptGeneratorTest < Test::Unit::TestCase
  context "The JavascriptGenerator" do
    should "raise an error if no framework passed" do
      assert_raises RuntimeError do
        Apotomo::JavascriptGenerator.new(nil)
      end
    end
    
    context "in prototype mode" do
      setup do
        @gen = Apotomo::JavascriptGenerator.new(:prototype)
      end
      
      should "respond to prototype" do
        assert_respond_to @gen, :prototype
      end
      
      should "respond to replace" do
        assert_equal "$(\"drinks\").replace(\"EMPTY!\");", @gen.replace(:drinks, 'EMPTY!')
      end
      
      should "respond to replace_id" do
        assert_equal "$(\"drinks\").replace(\"EMPTY!\");", @gen.replace_id("drinks", 'EMPTY!')
      end
      
      should "respond to update" do
        assert_equal "$(\"drinks\").update(\"<li id=\\\"beer\\\"><\\/li>\");", @gen.update(:drinks, '<li id="beer"></li>')
      end
      
      should "respond to update_id" do
        assert_equal "$(\"drinks\").update(\"EMPTY!\");", @gen.update_id("drinks", 'EMPTY!')
      end
    end
    
    context "in right mode" do
      setup do
        @gen = Apotomo::JavascriptGenerator.new(:right)
      end
      
      should "respond to right" do
        assert_respond_to @gen, :right
      end
      
      should "respond to replace" do
        assert_equal "$(\"drinks\").replace(\"EMPTY!\");", @gen.replace(:drinks, 'EMPTY!')
      end
      
      should "respond to replace_id" do
        assert_equal "$(\"drinks\").replace(\"EMPTY!\");", @gen.replace_id("drinks", 'EMPTY!')
      end
      
      should "respond to update" do
        assert_equal "$(\"drinks\").update(\"<li id=\\\"beer\\\"><\\/li>\");", @gen.update(:drinks, '<li id="beer"></li>')
      end
      
      should "respond to update_id" do
        assert_equal "$(\"drinks\").update(\"EMPTY!\");", @gen.update_id("drinks", 'EMPTY!')
      end
    end
    
    context "in jquery mode" do
      setup do
        @gen = Apotomo::JavascriptGenerator.new(:jquery)
      end

      should 'create _apo_xyz javascript variable for jQuery element' do
        assert_equal "var _apo_xyz = $(\"#my_id\").find(\".item\");", @gen.selector_for(:xyz, 'my_id', '.item')
      end
      
      should "respond to jquery" do
        assert_respond_to @gen, :jquery
      end
    
      should "respond to replace" do
        assert_equal "$(\"#drinks\").replaceWith(\"EMPTY!\");", @gen.replace("#drinks", 'EMPTY!')
      end

      should "escape" do
        assert_equal "<li id=\\\"beer\\\"><\\/li>", @gen.escape('<li id="beer"></li>')
      end

      should "respond to replace and escape" do
        assert_equal "$(\"#drinks\").replaceWith(\"<li id=\\\"beer\\\"><\\/li>\");", @gen.replace("#drinks", '<li id="beer"></li>')
      end

      should "respond to replace with block" do
        txt = @gen.replace("#drinks") { '<li id="beer"></li>'}
        assert_equal "$(\"#drinks\").replaceWith(\"<li id=\\\"beer\\\"><\\/li>\");", txt
      end
      
      should "respond to replace_id" do
        assert_equal "$(\"#drinks\").replaceWith(\"EMPTY!\");", @gen.replace_id("drinks", 'EMPTY!')
      end
      
      should "respond to update and escape" do
        assert_equal "$(\"#drinks\").html(\"<li id=\\\"beer\\\"><\\/li>\");", @gen.update("#drinks", '<li id="beer"></li>')
      end

      should "respond to update with block" do
        txt = @gen.update("#drinks") { '<li id="beer"></li>'}
        assert_equal "$(\"#drinks\").html(\"<li id=\\\"beer\\\"><\\/li>\");", txt
      end
      
      should "respond to update_id" do
        assert_equal "$(\"#drinks\").html(\"EMPTY!\");", @gen.update_id("drinks", 'EMPTY!')
      end
    end
  end
end
