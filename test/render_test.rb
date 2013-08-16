require 'test_helper'

class RenderTest < MiniTest::Spec
  include Apotomo::TestCaseMethods::TestController

  describe "#render" do
    before do
      @mum = mouse('mum')
    end

    it "per default display the state content framed in a div" do
      assert_equal '<div id="mum">burp!</div>', @mum.invoke(:eating)
    end

    describe "with :text" do
      before do
        @mum.instance_eval { def eating; render :text => "burp!!!"; end }
      end

      it "render the :text" do
        assert_equal "burp!!!", @mum.invoke(:eating)
      end
    end

    it "accept :state and options" do
      @mum.instance_eval { def eat(what); render :text => "#{what} today?"; end }

      assert_equal "Rice today?", @mum.render({:state => :eat}, "Rice")
      assert_match "Rice today?", @mum.update({:state => :eat}, "Rice")
      assert_match "Rice today?", @mum.replace({:state => :eat}, "Rice")
    end

    it "expose its instance variables in the rendered view" do
      @mum = mouse('mum') do
        def educate
          @who  = "the cat"
          @what = "run away"
          render
        end
      end
      assert_equal 'If you see the cat do run away!', @mum.invoke(:educate)
    end

    describe "with #render" do
      describe "and :text" do
        before do
          @mum.instance_eval do
            def squeak
              render :text => "squeak();"
            end
          end
        end

        it "just return the plain :text" do
          assert_equal 'squeak();', @mum.invoke(:squeak)
        end
      end

      describe "and no options" do
        before do
          @mum.instance_eval do
            def squeak
              render
            end
          end
        end

        it "render the view" do
          assert_equal "<div id=\"mum\">burp!</div>",  @mum.invoke(:eating)
        end
      end

      describe "and :view" do
        before do
          @mum.instance_eval do
            def squeak
              render :view => :eating
            end
          end
        end

        it "render the :view" do
          assert_equal "<div id=\"mum\">burp!</div>", @mum.invoke(:squeak)
        end
      end
    end

    describe "#update" do
      it "wrap the :text in an update statement" do
        @mum.instance_eval do
          def squeak
            update :text => "squeak!"
          end
        end
        assert_equal "jQuery(\"#mum\").html(\"squeak!\");", @mum.invoke(:squeak)
      end

      it "accept a selector" do
        @mum.instance_eval do
          def squeak
            update "div#mouse", :text => '<div id="mum">squeak!</div>'
          end
        end
        assert_equal "jQuery(\"div#mouse\").html(\"<div id=\\\"mum\\\">squeak!<\\/div>\");", @mum.invoke(:squeak)
      end
    end

    describe "#replace" do
      it "wrap the :text in a replace statement" do
        @mum.instance_eval do
          def squeak
            replace :text => '<div id="mum">squeak!</div>'
          end
        end
        assert_equal "jQuery(\"#mum\").replaceWith(\"<div id=\\\"mum\\\">squeak!<\\/div>\");", @mum.invoke(:squeak)
      end

      it "accept a selector" do
        @mum.instance_eval do
          def squeak
            replace "div#mouse", :text => '<div id="mum">squeak!</div>'
          end
        end
        assert_equal "jQuery(\"div#mouse\").replaceWith(\"<div id=\\\"mum\\\">squeak!<\\/div>\");", @mum.invoke(:squeak)
      end
    end

    describe "#escape_js" do
      it "escape the string" do
        assert_equal "<div id=\\\"mum\\\">squeak!<\\/div>", @mum.escape_js('<div id="mum">squeak!</div>')
      end
    end

    describe "#js_generator" do
      it "return JavascriptGenerator object" do
        assert_equal Apotomo.js_generator, @mum.js_generator
      end
    end
  end
end
