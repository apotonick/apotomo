require 'test_helper'

class WidgetTest < ActiveSupport::TestCase
  include Apotomo::TestCaseMethods::TestController

  context "The constructor" do
    should "accept the parent_controller as first arg" do
      assert_kind_of ActionController::Base, @controller
      @mum = Apotomo::Widget.new(@controller, 'mum', :squeak)
    end
  end

  context "Widget.has_widgets" do
    setup do
      @mum = Class.new(MouseWidget) do
        has_widgets do |me|
          me << widget(:mouse, :baby)
          #MouseWidget.new(me, :baby) # this is also possible.
        end
      end.new(@controller, 'mum')

      @kid = Class.new(@mum.class).new(@controller, 'mum')
    end

    should "setup the widget family at creation time" do
      assert_equal 1, @mum.children.size
      assert_kind_of MouseWidget, @mum[:baby]
    end

    should "inherit trees for now" do
      assert_equal 1, @mum.children.size
      assert_kind_of MouseWidget, @mum[:baby]
    end
  end


  context "A widget" do
    setup do
      @mum = Apotomo::Widget.new(@controller, 'mum', :squeak)
    end

    context "responding to #address_for_event" do
      should "accept an event :type" do
        assert_equal({:source=>"mum", :type=>:squeak, :controller=>"barn"}, @mum.address_for_event(:squeak))
      end

      should "accept a :source" do
        assert_equal({:source=>"kid", :type=>:squeak, :controller=>"barn"}, @mum.address_for_event(:squeak, :source => 'kid'))
      end

      should "accept arbitrary options" do
        assert_equal({:volume=>"loud", :source=>"mum", :type=>:squeak, :controller=>"barn"}, @mum.address_for_event(:squeak, :volume => 'loud'))
      end

      should "work with controller namespaces" do
        @mum = Apotomo::Widget.new(namespaced_controller, 'mum', :squeak)
        assert_equal({:source=>"mum", :type=>:squeak, :controller=>"farm/barn"}, @mum.address_for_event(:squeak))
      end
    end

    context "implementing visibility" do
      should "per default respond to #visible?" do
        assert @mum.visible?
      end

      should "expose a setter therefore" do
        @mum.visible = false
        assert_not @mum.visible?
      end
    end

    context "#find_widget" do
      setup do
        mum_and_kid!
      end

      should "find itself" do
        assert_equal @mum, @mum.find_widget('mum')
      end

      should "return nil for not-existant widgets" do
        assert_nil @mum.find_widget('pet')
      end

      should "find children" do
        assert_equal @kid, @mum.find_widget('kid')
      end

      should "find treat 'id' and :id the same" do
        assert_equal @mum.find_widget(:kid), @mum.find_widget('kid')
      end
    end

    should "respond to the WidgetShortcuts methods, like #widget" do
      assert_respond_to @mum, :widget
    end

    should "respond to #parent_controller and return the AC in root" do
      @mum << mouse_mock(:kid)
      assert_equal @controller, @mum.parent_controller
      assert_equal @controller, @mum[:kid].parent_controller
    end

    should "alias #widget_id to #name" do
      assert_equal @mum.name, @mum.widget_id
    end

    should "respond to DEFAULT_VIEW_PATHS" do
      assert_equal ["app/widgets"], Apotomo::Widget::DEFAULT_VIEW_PATHS
    end

    should "respond to .view_paths" do
      if Cell.rails3_2_or_more?
        assert_equal ActionView::PathSet.new(Apotomo::Widget::DEFAULT_VIEW_PATHS + ["test/widgets"]).paths, Apotomo::Widget.view_paths.paths
      else
        assert_equal ActionView::PathSet.new(Apotomo::Widget::DEFAULT_VIEW_PATHS + ["test/widgets"]), Apotomo::Widget.view_paths
      end
    end

    should "respond to .controller_path" do
      assert_equal "mouse", MouseWidget.controller_path
    end

    # internal_methods:
    should "not list internal methods in action_methods" do
      # FIXME: puts "WTF is wrong again with AC.action_methods godamn, I HATE this magic shit!"
      unless Cell.rails3_1_or_more?
        assert_equal [], Class.new(Apotomo::Widget).action_methods
      end
    end

    should "list both local and inherited states in Widget.action_methods" do
      assert MouseWidget.action_methods.collect{ |m| m.to_s }.include?("squeak")
      assert Class.new(MouseWidget).action_methods.collect{ |m| m.to_s }.include?("squeak")
    end

    should "list 'load' in local and inherited states in Widget.action_methods" do
      assert MouseWidget.action_methods.collect{ |m| m.to_s }.include?("load")
      assert Class.new(MouseWidget).action_methods.collect{ |m| m.to_s }.include?("load")
    end

    should "not list #display in internal_methods although it's defined in Object" do
      assert_not Apotomo::Widget.internal_methods.include?(:display)
    end
  end
end


class RenderWidgetTest < ActiveSupport::TestCase
  include Apotomo::TestCaseMethods::TestController

  context "#render_widget" do
    should "allow passing widget id" do
      assert_equal "squeak!", mouse.render_widget('mouse', :squeak)
    end

    should "allow passing widget instance" do
      assert_equal 'squeak!', mouse.render_widget(mouse(:mum), :squeak)
    end

    should "use :display as standard state" do
      mum = mouse('Mum') do
        def display
          render :text => "#{widget_id}, that's me!"
        end
      end

      assert_equal "Mum, that's me!", mouse.render_widget(mum)
    end

    should "raise an exception when a non-existent widget id is passed" do
      e = assert_raises RuntimeError do
        mouse.render_widget('mummy')
      end

      assert_equal "Couldn't render non-existent widget `mummy`", e.message
    end

    should "pass options as state-args" do
      mum = mouse do
        def display(color="grey")
          render :text => "I'm #{color}"
        end
      end

      assert_equal("I'm grey", mouse.render_widget(mum), "default value in state-arg didn't work")
      assert_equal("I'm black", mouse.render_widget(mum, :display, "black"))
    end

    should "use #find_widget from self to find the passed widget id" do
      mum = mouse << mouse_mock(:kid)

      assert_equal "<div id=\"kid\">burp!</div>\n", mum.render_widget(:kid, :eat)
    end
  end
end
