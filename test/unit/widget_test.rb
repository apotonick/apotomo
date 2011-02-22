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
          me << widget(:mouse, 'baby', :squeak)
        end
      end.new(@controller, 'mum', :squeak)
      
      @kid = Class.new(@mum.class).new(@controller, 'mum', :squeak)
    end
    
    should "setup the widget family at creation time" do
      assert_equal 1, @mum.children.size
      assert_kind_of Apotomo::Widget, @mum['baby']
    end
    
    should "inherit trees for now" do
      assert_equal 1, @mum.children.size
      assert_kind_of Apotomo::Widget, @mum['baby']
    end
  end
  
  context "Widget.after_add" do
    setup do
      @mum = Class.new(MouseWidget) do
        after_add do |me, parent|
          parent << widget(:mouse, 'kid', :squeak)
        end
      end.new(@controller, 'mum', :squeak)
      
      @root = mouse_mock('root')
    end
    
    should "be invoked after mum is added" do
      assert_equal [], @root.children
      @root << @mum
      
      assert_equal ['mum', 'kid'], @root.children.collect { |w| w.name }
    end
    
    should "inherit callbacks for now" do
      @berry = Class.new(@mum.class).new(@controller, 'berry', :squeak)
      @root << @berry
      
      assert_equal ['berry', 'kid'], @root.children.collect { |w| w.name }
    end
  end

  context "A stateless widget" do
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
      
      context "in a widget family" do
        setup do
          @mum << @jerry = mouse_mock('jerry')
          @mum << @berry = mouse_mock('berry')
        end
        
        should "per default return all #visible_children" do
          assert_equal [@jerry, @berry], @mum.visible_children
          assert_equal [], @jerry.visible_children
        end
        
        should "hide berry in #visible_children if he's invisible" do
          @berry.visible = false
          assert_equal [@jerry], @mum.visible_children
        end
      end
    end
    
    should "respond to #find_widget" do
      mum_and_kid!
      assert_not @mum.find_widget('pet')
      assert_equal @kid, @mum.find_widget('kid')
    end
    
    should "respond to the WidgetShortcuts methods, like #widget" do
      assert_respond_to @mum, :widget
    end
    
    should "respond to #parent_controller" do
      assert_equal @controller, @mum.parent_controller
    end
    
    should "alias #widget_id to #name" do
      assert_equal @mum.name, @mum.widget_id
    end
    
    should "mark #param as deprecated" do
      assert_raises RuntimeError do
        @mum.param(:volume)
      end
    end
    
    should "respond to DEFAULT_VIEW_PATHS" do
      assert_equal ["app/widgets", "app/widgets/layouts"], Apotomo::Widget::DEFAULT_VIEW_PATHS
    end
    
    should "respond to .view_paths" do
      assert_equal ActionView::PathSet.new(Apotomo::Widget::DEFAULT_VIEW_PATHS + ["test/widgets"]), Apotomo::Widget.view_paths
    end
    
    should "respond to .controller_path" do
      assert_equal "mouse", MouseWidget.controller_path
    end
    
    # internal_methods:
    should "not list internal methods in action_methods" do
      assert_equal [], Class.new(Apotomo::Widget).action_methods
    end
    
    should "list both local and inherited states in Widget.action_methods" do
      assert MouseWidget.action_methods.collect{ |m| m.to_s }.include?("squeak")
      assert Class.new(MouseWidget).action_methods.collect{ |m| m.to_s }.include?("squeak")
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
      assert_equal "squeak!", mouse_mock.render_widget('mouse', :squeak)
    end
    
    should "allow passing widget instance" do
      assert_equal 'squeak!', mouse_mock.render_widget(mouse_mock('mum'), :squeak)
    end
    
    should "use :display as standard state" do
      mum = mouse_mock('Mum') do
        def display
          render :text => "#{widget_id}, that's me!"
        end
      end
      
      assert_equal "Mum, that's me!", mouse_mock.render_widget(mum)
    end
    
    should "raise an exception when a non-existent widget id is passed" do
      e = assert_raises RuntimeError do
        mouse_mock.render_widget('mummy')
      end
      
      assert_equal "Couldn't render non-existent widget `mummy`", e.message
    end
    
    should "pass options as state-args" do
      mum = mouse_mock do
        def display(color="grey")
          render :text => "I'm #{color}"
        end
      end
      
      assert_equal("I'm grey", mouse_mock.render_widget(mum), "default value in state-arg didn't work")
      assert_equal("I'm black", mouse_mock.render_widget(mum, :display, "black"))
    end
    
    should "use #find_widget from self to find the passed widget id" do
      mum = mouse_mock('mum') << mouse_mock(:kid)
      
      assert_equal "<div id=\"kid\">burp!</div>\n", mum.render_widget(:kid, :eat)
    end 
  end
end
