require File.dirname(__FILE__) + '/../test_helper'


class JavascriptGeneratorTest < Test::Unit::TestCase
  context "The JavascriptGenerator" do
    context "in prototype mode" do
      setup do
        @gen = Apotomo::JavascriptGenerator.new(:prototype)
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
  end
end