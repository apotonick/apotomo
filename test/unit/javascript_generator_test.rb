require File.dirname(__FILE__) + '/../test_helper'


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
    
      should "respond to xhr" do
        assert_equal "new Ajax.Request(\"/drink/beer?source=nick\")", @gen.xhr('/drink/beer?source=nick')
      end
      
      should "respond to replace" do
        assert_equal "$(\"drinks\").replace(\"EMPTY!\")", @gen.replace(:drinks, 'EMPTY!')
      end
      
      should "respond to update" do
        assert_equal "$(\"drinks\").update(\"<li id=\\\"beer\\\"><\\/li>\")", @gen.update(:drinks, '<li id="beer"></li>')
      end
      
      should "respond to <<" do
        assert_equal "alert(\"Beer!\")", @gen << 'alert("Beer!")'
      end
    end
    
    context "in right mode" do
      setup do
        @gen = Apotomo::JavascriptGenerator.new(:right)
      end
      
      should "respond to right" do
        assert_respond_to @gen, :right
      end
    
      should "respond to xhr" do
        assert_equal "new Xhr(\"/drink/beer?source=nick\", {evalScripts:true}).send()", @gen.xhr('/drink/beer?source=nick')
      end
      
      should "respond to replace" do
        assert_equal "$(\"drinks\").replace(\"EMPTY!\")", @gen.replace(:drinks, 'EMPTY!')
      end
      
      should "respond to update" do
        assert_equal "$(\"drinks\").update(\"<li id=\\\"beer\\\"><\\/li>\")", @gen.update(:drinks, '<li id="beer"></li>')
      end
      
      should "respond to <<" do
        assert_equal "alert(\"Beer!\")", @gen << 'alert("Beer!")'
      end
    end
    
    context "in jquery mode" do
      setup do
        @gen = Apotomo::JavascriptGenerator.new(:jquery)
      end
      
      should "respond to jquery" do
        assert_respond_to @gen, :jquery
      end
    
      should "respond to xhr" do
        assert_equal "$.ajax({url: \"/drink/beer?source=nick\"})", @gen.xhr('/drink/beer?source=nick')
      end
      
      should "respond to replace" do
        assert_equal "$(\"#drinks\").replaceWith(\"EMPTY!\")", @gen.replace(:drinks, 'EMPTY!')
      end
      
      should "respond to update" do
        assert_equal "$(\"#drinks\").html(\"<li id=\\\"beer\\\"><\\/li>\")", @gen.update(:drinks, '<li id="beer"></li>')
      end
      
      should "respond to <<" do
        assert_equal "alert(\"Beer!\")", @gen << 'alert("Beer!")'
      end
    end
  end
end