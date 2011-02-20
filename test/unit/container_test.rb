require 'test_helper'
require 'apotomo/container_widget'

class ContainerTest < Test::Unit::TestCase
  include Apotomo::TestCaseMethods::TestController
  
  context "Rendering a container" do
    setup do
      @family = container('family')
    end
    
    should "return an empty view if childless" do
      assert_equal "<div id=\"family\"></div>", @family.invoke
    end
    
    should "provide a family picture" do
      @family << mouse_mock('mum', :eating)
      @family << mouse_mock('kid', :eating)
      assert_equal "<div id=\"family\"><div id=\"mum\">burp!</div>\n<div id=\"kid\">burp!</div></div>", @family.invoke
    end
  end
end
