require 'test_helper'

class RenderTest < ActionView::TestCase
  include Apotomo::TestCaseMethods::TestController
  
  context "#render" do
    setup do
      @mum = mouse('mum')
    end
    
    should "per default display the state content framed in a div" do
      assert_equal '<div id="mum">burp!</div>', @mum.invoke(:eating)
    end
    
    context "with :text" do
      setup do
        @mum.instance_eval { def eating; render :text => "burp!!!"; end }
      end
      
      should "render the :text" do
        assert_equal "burp!!!", @mum.invoke(:eating)
      end
    end
    
    should "accept :state and options" do
      @mum.instance_eval { def eat(what); render :text => "#{what} today?"; end }
      
      assert_equal "Rice today?", @mum.render({:state => :eat}, "Rice")
      assert_match "Rice today?", @mum.update({:state => :eat}, "Rice")
      assert_match "Rice today?", @mum.replace({:state => :eat}, "Rice")
    end
    
    should "expose its instance variables in the rendered view" do
      @mum = mouse('mum') do
        def educate
          @who  = "the cat"
          @what = "run away"
          render
        end
      end
      assert_equal 'If you see the cat do run away!', @mum.invoke(:educate)
    end
    
    context "with #render" do
      context "and :text" do
        setup do
          @mum.instance_eval do
            def squeak
              render :text => "squeak();"
            end
          end
        end
        
        should "just return the plain :text" do
          assert_equal 'squeak();', @mum.invoke(:squeak)
        end
      end
      
      context "and no options" do
        setup do
          @mum.instance_eval do
            def squeak
              render
            end
          end
        end
        
        should "render the view" do
          assert_equal "<div id=\"mum\">burp!</div>",  @mum.invoke(:eating)
        end
      end
      
      context "and :view" do
        setup do
          @mum.instance_eval do
            def squeak
              render :view => :eating
            end
          end
        end
        
        should "render the :view" do
          assert_equal "<div id=\"mum\">burp!</div>", @mum.invoke(:squeak)
        end
      end
    end
    
    context "#update" do
      should "wrap the :text in an update statement" do
        @mum.instance_eval do
          def squeak
            update :text => "squeak!"
          end
        end
        assert_equal "jQuery(\"#mum\").html(\"squeak!\");", @mum.invoke(:squeak)
      end
      
      should "accept a selector" do
        @mum.instance_eval do
          def squeak
            update "div#mouse", :text => '<div id="mum">squeak!</div>'
          end
        end
        assert_equal "jQuery(\"div#mouse\").html(\"<div id=\\\"mum\\\">squeak!<\\/div>\");", @mum.invoke(:squeak)
      end
    end
    
    context "#replace" do
      should "wrap the :text in a replace statement" do
        @mum.instance_eval do
          def squeak
            replace :text => '<div id="mum">squeak!</div>'
          end
        end
        assert_equal "jQuery(\"#mum\").replaceWith(\"<div id=\\\"mum\\\">squeak!<\\/div>\");", @mum.invoke(:squeak)
      end
      
      should "accept a selector" do
        @mum.instance_eval do
          def squeak
            replace "div#mouse", :text => '<div id="mum">squeak!</div>'
          end
        end
        assert_equal "jQuery(\"div#mouse\").replaceWith(\"<div id=\\\"mum\\\">squeak!<\\/div>\");", @mum.invoke(:squeak)
      end
    end
    
    context "#escape_js" do
      should "escape the string" do
        assert_equal "<div id=\\\"mum\\\">squeak!<\\/div>", @mum.escape_js('<div id="mum">squeak!</div>')
      end
    end
  end  
end
