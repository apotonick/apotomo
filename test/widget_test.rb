require 'test_helper'

# TODO: there are things aren't tested here

class WidgetTest < MiniTest::Spec
  include Apotomo::TestCaseMethods::TestController

  describe "::has_widgets" do
    before do
      @mum = Class.new(MouseWidget) do
        has_widgets do |me|
          me << widget(:mouse, :baby)
          # MouseWidget.new(me, :baby) # this is also possible.
        end
      end.new(@controller, 'mum')

      @kid = Class.new(@mum.class).new(@controller, 'mum')
    end

    # TODO: check when hook is called

    # TODO: check if block yielded
    # TODO: what block gets

    it "inherit tree" do
      assert_equal 1, @mum.children.size
      assert_kind_of MouseWidget, @mum[:baby]
    end
  end

  describe "Widget" do
    before do
      @mum = Apotomo::Widget.new(@controller, 'mum', :squeak)
    end

    describe "#address_for_event" do
      it "accept an event :type" do
        assert_equal({:source=>"mum", :type=>:squeak, :controller=>"barn"}, @mum.address_for_event(:squeak))
      end

      it "accept a :source option" do
        assert_equal({:source=>"kid", :type=>:squeak, :controller=>"barn"}, @mum.address_for_event(:squeak, :source => 'kid'))
      end

      it "accept a :type option" do
        assert_equal({:source=>"mum", :type=>:eating, :controller=>"barn"}, @mum.address_for_event(:squeak, :type => :eating))
      end

      it "accept a :controller option" do
        assert_equal({:source=>"mum", :type=>:squeak, :controller=>"farm/barn"}, @mum.address_for_event(:squeak, :controller => "farm/barn"))
      end

      it "accept arbitrary options" do
        assert_equal({:volume=>"loud", :source=>"mum", :type=>:squeak, :controller=>"barn"}, @mum.address_for_event(:squeak, :volume => 'loud'))
      end

      it "work with a namespaced controller" do
        @mum = Apotomo::Widget.new(namespaced_controller, 'mum', :squeak)
        assert_equal({:source=>"mum", :type=>:squeak, :controller=>"farm/barn"}, @mum.address_for_event(:squeak))
      end
    end

    describe "visibility" do
      it "it respond to #visible? and per default is visible" do
        assert @mum.visible?
      end

      it "expose a setter therefore" do
        @mum.visible = false
        assert_not @mum.visible?
      end
    end

    describe "#find_widget" do
      before do
        mum_and_kid!
      end

      it "find existant widgets" do
        assert_equal @mum, @mum.find_widget('mum')
        assert_equal @kid, @mum.find_widget('kid')
        # TODO: find grandchild
        # TODO: find foreign widgets (i.e. brother)
      end

      it "return nil for not-existant widgets" do
        assert_nil @mum.find_widget('pet')
      end

      it "find treat 'id' and :id the same" do
        assert_equal @mum.find_widget(:kid), @mum.find_widget('kid')
      end
    end

    it "respond to #parent_controller" do
      @mum << mouse_mock(:kid)
      assert_equal @controller, @mum.parent_controller
      assert_equal @controller, @mum[:kid].parent_controller
    end

    it "alias #widget_id to #name" do
      assert_equal @mum.name, @mum.widget_id
    end

    it "respond to #DEFAULT_VIEW_PATHS" do
      assert_equal ["app/widgets"], Apotomo::Widget::DEFAULT_VIEW_PATHS
    end

    it "respond to #view_paths" do # DISCUSS: why we test it?
      if Cell.rails3_2_or_more?
        assert_equal ActionView::PathSet.new(Apotomo::Widget::DEFAULT_VIEW_PATHS + ["test/widgets"]).paths, Apotomo::Widget.view_paths.paths
      else
        assert_equal ActionView::PathSet.new(Apotomo::Widget::DEFAULT_VIEW_PATHS + ["test/widgets"]), Apotomo::Widget.view_paths
      end
    end

    it "not list internal methods in action_methods" do
      # FIXME: puts "WTF is wrong again with AC.action_methods godamn, I HATE this magic shit!"
      unless Cell.rails3_1_or_more?
        assert Class.new(Apotomo::Widget).action_methods.empty?
      end
    end

    it "list both local and inherited states in #action_methods" do
      assert MouseWidget.action_methods.collect(&:to_s).include?("squeak")
      assert Class.new(MouseWidget).action_methods.collect(&:to_s).include?("squeak")
    end

    it "not list #display in #internal_methods although it's defined in Object" do
      assert_not Apotomo::Widget.internal_methods.include?(:display)
    end
  end

  describe "#render_widget" do
    it "allow passing widget id" do
      assert_equal "squeak!", mouse.render_widget('mouse', :squeak)
    end

    it "allow passing widget instance" do
      assert_equal 'squeak!', mouse.render_widget(mouse(:mum), :squeak)
    end

    it "use :display as standard state" do
      mum = mouse('Mum') do
        def display
          render :text => "#{widget_id}, that's me!"
        end
      end

      assert_equal "Mum, that's me!", mouse.render_widget(mum)
    end

    it "raise an exception when a non-existent widget id is passed" do
      e = assert_raises RuntimeError do
        mouse.render_widget('mummy')
      end

      assert_equal "Couldn't render non-existent widget `mummy`", e.message
    end

    it "pass options as state-args" do
      mum = mouse do
        def display(color="grey")
          render :text => "I'm #{color}"
        end
      end

      assert_equal "I'm grey", mouse.render_widget(mum)
      assert_equal "I'm black", mouse.render_widget(mum, :display, "black")
    end

    it "treat widget id as a descedant's id" do
      mum = mouse << mouse_mock(:kid)

      assert_equal "<div id=\"kid\">burp!</div>\n", mum.render_widget(:kid, :eat)
    end
  end
end
