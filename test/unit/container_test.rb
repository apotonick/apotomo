require 'test_helper'

class ContainerTest < Test::Unit::TestCase
  context "Rendering a container" do
    setup do
      @family = container('family')
      @family.controller = @controller
    end
    
    should "return an empty view if childless" do
      assert_equal "<div id=\"family\"></div>", @family.invoke
    end
    
    should "provide a family picture" do
      @family << mouse_mock('mum')
      @family << mouse_mock('kid')
      assert_equal "<div id=\"family\"><div id=\"mum\">burp!</div>\n<div id=\"kid\">burp!</div></div>", @family.invoke
    end
  end
end
