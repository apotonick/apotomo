require File.join(File.dirname(__FILE__), *%w[.. test_helper])

class RenderTest < ActionView::TestCase
  context "Rendering a single widget" do
    setup do
      @mum = mouse_mock
    end
    
    should "per default display the state content framed in a div" do
      assert_equal '<div id="mouse">burp!</div>', @mum.invoke(:eating)
    end
    
    should "omit the framing div if :frame is false" do
      @mum.instance_eval { def eating; render :frame => false; end }
      assert_equal 'burp!', @mum.invoke(:eating)
    end
    
    should "frame the content in a <p> if :frame is :p" do
      @mum.instance_eval { def eating; render :frame => :p; end }
      assert_equal '<p id="mouse">burp!</p>', @mum.invoke(:eating)
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
    
    context "with :text" do
      setup do
        @mum.instance_eval { def eating; render :text => "burp!!!"; end }
      end
      
      should "per default omit the frame" do
        assert_equal "burp!!!", @mum.invoke
      end
      
      should "add a frame if it is explicitely set" do
        @mum.instance_eval { def eating; render :text => "burp!!!", :frame => :div; end }
        assert_equal '<div id="mouse">burp!!!</div>', @mum.invoke
      end
    end
    
    context "with :update" do
      setup do
        @mum.instance_eval { def eating; render :update => true; end }
      end
      
      should "per default omit the frame as it is updating the inner html" do
        assert_equal "burp!", @mum.invoke
      end
      
      should "add a frame if it is explicitely set" do
        @mum.instance_eval { def eating; render :update => true, :frame => :div; end }
        assert_equal '<div id="mouse">burp!</div>', @mum.invoke
      end
    end
    
    context "with :js" do
      should "return a Javascript object per default" do
        @mum.instance_eval do
          def squeak; render :js => 'squeak();'; end
        end
        assert_kind_of ::Apotomo::Content::Javascript, @mum.invoke(:squeak)
      end
      
      should_eventually "generate javascript when called with a block" do
      ### DISCUSS: eventually provide a generator object (for rightjs)?
        @mum.instance_eval do
          def squeak
            render :js do |page|
              page[:mum].insert_html(:below, "<p>squeak</p>")
            end
          end
        end
        assert_equal 'Element.insert("mum", { below: "<p>squeak</p>" });', @mum.invoke(:squeak)
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
    
    context "with :view" do
      setup do
        @mum.instance_eval do
          def squeak; render :view => :squeak; end
        end
      end
      
      should ""
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
    
    should "invoke kid even if :text is passed" do
      @mum.instance_eval { def snuggle; render :text => "snuggle!"; end }
      assert_not @kid.last_state
      assert_equal 'snuggle!', @mum.invoke
      assert_equal :eating, @kid.last_state
    end
    
    should_eventually "provide an ordered rendered_children hash"
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
  
  
  context "In default rendering context" do
    setup do
      @mum = mouse_mock do
        def eating; render; end
      end
    end
    
    context "the returned content" do
      should "be wrapped in a PageUpdate object" do
        assert_kind_of Apotomo::Content::PageUpdate, @mum.invoke
      end
      
      should "respond to #replace?" do
        assert @mum.invoke.replace?
        assert_not @mum.invoke.update?
      end
      
      should "respond to #update? when setting :update" do
        @mum.instance_eval { def eating; render :update => true; end }
        assert_not @mum.invoke.replace?
        assert @mum.invoke.update?
      end
    end
  end
end