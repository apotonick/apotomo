require 'test_helper'

# DISCUSS: refactor this test?
# DISCUSS: merge into another test?
# DISCUSS: why we should test #render if it just calls Cell#render (it is tested in cells)?
# DISCUSS: test #wrap_in_javascript_for and if every method calls it?

class RenderTest < MiniTest::Spec
  include Apotomo::TestCaseMethods::TestController

  describe "#render" do
    before do
      @mum = mouse('mum')
    end

    it "render the view without options" do
      @mum.instance_eval do
        def eating
          render
        end
      end

      assert_equal "<div id=\"mum\">burp!</div>",  @mum.invoke(:eating)
    end

    it "render the :text" do
      @mum.instance_eval do
        def eating
          render :text => "burp!!!"
        end
      end

      assert_equal "burp!!!", @mum.invoke(:eating)
    end

    it "render the :state" do
      @mum.instance_eval do
        def eating
          render :text => "burp!!!"
        end
      end

      assert_equal "burp!!!", @mum.render(:state => :eating)
    end

    it "accept :state and options" do
      @mum.instance_eval do
        def eat(what)
          render :text => "#{what} today?"
        end
      end

      assert_equal "Rice today?", @mum.render({:state => :eat}, "Rice")
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

    it "render the :view" do
      @mum.instance_eval do
        def squeak
          render :view => :eating
        end
      end

      assert_equal "<div id=\"mum\">burp!</div>", @mum.invoke(:squeak)
    end
  end

  describe "#update" do
    before do
      @mum = mouse('mum')
    end

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
    before do
      @mum = mouse('mum')
    end

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
    before do
      @mum = mouse('mum')
    end

    it "escape the string" do
      assert_equal "<div id=\\\"mum\\\">squeak!<\\/div>", @mum.escape_js('<div id="mum">squeak!</div>')
    end
  end
end
