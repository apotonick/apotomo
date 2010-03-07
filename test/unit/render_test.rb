require File.join(File.dirname(__FILE__), *%w[.. test_helper])

class RenderTest < Test::Unit::TestCase
  context "rendering a single widget" do
    setup do
      @mum = mouse_mock
    end
    
    should "per default display the state content framed in a div" do
      assert_equal '<div id="mouse">burp!</div>', @mum.invoke(:eating)
    end
  end
  
  context "rendering a widget family" do
    setup do
      @mum = mouse_mock('mum', :snuggle) do
        def snuggle; render; end
      end
      
      @mum << mouse_mock('kid')
    end
    
    should "per default render kid's content inside mums div" do
      assert_equal '<div id="mum"><snuggle><div id="kid">burp!</div></snuggle></div>', @mum.invoke(:snuggle)
    end
  end
  
end