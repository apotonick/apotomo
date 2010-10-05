require 'test_helper'

class RenderTest < ActionView::TestCase
  context "Rendering a single widget" do
    setup do
      @mum = mouse_mock
    end
    
    should "per default display the state content framed in a div" do
      assert_equal '<div id="mouse">burp!</div>', @mum.invoke(:eating)
    end
    
    context "with :text" do
      setup do
        @mum.instance_eval { def eating; render :text => "burp!!!"; end }
      end
      
      should "render the :text" do
        assert_equal "burp!!!", @mum.invoke
      end
    end
    
    
    context "with :suppress_js" do
      setup do
        @mum.instance_eval do
          def snuggle; render; end
          self.class.send :attr_reader, :suppress_js
        end
      end
      
      should "per default be false" do
        @mum.invoke :snuggle
        assert !@mum.suppress_js
      end
      
      should "be true when set" do
        @mum.instance_eval do
          def snuggle; render :suppress_js => true; end
        end
        @mum.invoke :snuggle
        assert @mum.suppress_js
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
      assert_equal 'If you see the cat do run away!', @mum.invoke(:educate)
    end
    
    context "with #emit" do
      setup do
        @kid = mouse_mock('kid', :squeak)
        @kid.instance_eval do
          def squeak
            render :text => "squeeeeaaak"
          end
          
          def render(*)
            @rendered = true
            super
          end
          def rendered?; @rendered; end
        end
      end
      
      context "and :text" do
        setup do
          @mum.instance_eval do
            def squeak
              emit :text => "squeak();"
            end
          end
        end
        
        should "just return the plain :text" do
          assert_equal 'squeak();', @mum.invoke(:squeak)
        end
        
        should "not render children" do
          @mum << @kid
          @mum.invoke(:squeak)
          
          assert_not @kid.rendered?
        end
        
        should "allow rendering children" do
          @mum.instance_eval do
            def squeak
              emit :text => "squeak();", :render_children => true
            end
          end
          @mum << @kid
          @mum.invoke(:squeak)
          
          assert @kid.rendered?
        end
      end
      
      context "and no options" do
        setup do
          @mum.instance_eval do
            def squeak
              emit
            end
          end
        end
        
        should "render the view" do
          assert_equal "<div id=\"mouse\">burp!</div>",  @mum.invoke(:eating)
        end
        
        should "render the children, too" do
          @mum << @kid
          @mum.invoke(:eating)
          assert @kid.rendered?
        end
      end
      
      context "and :view" do
        setup do
          @mum.instance_eval do
            def squeak
              emit :view => :snuggle
            end
          end
        end
        
        should "render the :view" do
          assert_equal "<div id=\"mouse\"><snuggle></snuggle></div>", @mum.invoke(:squeak)
        end
        
        should "render the children" do
          @mum << @kid
          
          assert_equal "<div id=\"mouse\"><snuggle>squeeeeaaak</snuggle></div>", @mum.invoke(:squeak)
          assert @kid.rendered?
        end
      end
    end
    
    context "with #update" do
      setup do
        Apotomo.js_framework = :prototype
      end
      
      should "wrap the :text in an update statement" do
        @mum.instance_eval do
          def squeak
            update :text => "squeak!"
          end
        end
        assert_equal "$(\"mouse\").update(\"squeak!\")", @mum.invoke(:squeak)
      end
    end
    
    context "with #replace" do
      setup do
        Apotomo.js_framework = :prototype
      end
      
      should "wrap the :text in a replace statement" do
        @mum.instance_eval do
          def squeak
            replace :text => '<div id="mum">squeak!</div>'
          end
        end
        assert_equal "$(\"mouse\").replace(\"<div id=\\\"mum\\\">squeak!<\\/div>\")", @mum.invoke(:squeak)
      end
    end
  end
  
  context "rendering a widget family" do
    setup do
      @mum = mouse_mock('mum', :snuggle) do
        def snuggle; render; end
      end
      
      @mum << @kid = mouse_mock('kid')
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
     
    should_eventually "provide an ordered rendered_children hash"
  end
  
end
