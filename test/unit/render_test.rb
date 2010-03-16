require File.join(File.dirname(__FILE__), *%w[.. test_helper])

class RenderTest < ActionView::TestCase
  context "Rendering a single widget" do
    setup do
      @mum = mouse_mock
    end
    
    should "per default display the state content framed in a div" do
      assert_equal '<div id="mouse">burp!</div>', @mum.invoke(:eating)
    end
    
    context "and accepting additional :html_options" do
      should "should add the options to the div and override even the id" do
        @mum.instance_eval do
          def eating; render :html_options => {:class => 'smack', :id => :piggy}; end
        end
        assert_dom_equal '<div id="piggy" class="smack">burp!</div>', @mum.invoke
      end
      
      should "should add the options to the div and use the default id" do
        @mum.instance_eval do
          def eating; render :html_options => {:class => 'smack'}; end
        end
        assert_dom_equal '<div id="mouse" class="smack">burp!</div>', @mum.invoke
      end
    end
    
    should "expose its instance variables in the rendered view" do
      @mum = mouse_mock('mum', :educate) do
        def educate
          @who  = "the cat"
          @what = "run away"
          render
        end
      end
      assert_equal '<div id="mum">If you see the cat do run away!</div>', @mum.invoke(:educate)
    end
  end
  
  context "rendering a widget family" do
    setup do
      @mum = mouse_mock('mum', :snuggle) do
        def snuggle; render; end
      end
      
      @mum << mouse_mock('kid')
    end
    
    should "per default render kid's content inside mums div with rendered_children" do
      assert_equal '<div id="mum"><snuggle><div id="kid">burp!</div></snuggle></div>', @mum.invoke(:snuggle)
    end
    
    should "skip kids if :render_children=>false but still provide a rendered_children hash" do
      @mum.instance_eval do
        def snuggle; render :render_children => false; end
      end
      
      assert_equal '<div id="mum"><snuggle></snuggle></div>', @mum.invoke(:snuggle)
    end
    
    should_eventually "provide an ordered hash rendered_children"
  end
  
  context "sending data with #render :raw" do
    setup do
      @mum = mouse_mock do
        def squeak; render :raw => "squeak\n"; end
      end
    end
    
    should "return a Content::Raw instance" do
      assert_kind_of Apotomo::Content::Raw, @mum.invoke(:squeak)
      assert_equal String.new("squeak\n"), @mum.invoke(:squeak)
    end
  end
end