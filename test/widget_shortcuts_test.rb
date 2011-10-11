require 'test_helper'

class MumWidget < MouseWidget; end
class MouseTabsWidget;end

class WidgetShortcutsTest < Test::Unit::TestCase
  context "FactoryProxy" do
    setup do
      @factory = Apotomo::WidgetShortcuts::FactoryProxy
    end
    
    context "#constant_for" do
      setup do
        @dsl = @factory.new(:class, :id)
      end
      
      should "constantize symbols" do
        assert_equal MouseWidget, @dsl.send(:constant_for, :mouse)
      end
  
      should "not try to singularize the widget class" do
        assert_equal MouseTabsWidget, @dsl.send(:constant_for, :mouse_tabs)
      end
    end
    
    context "#widget and #<<" do
      setup do
        @root = Apotomo::Widget.new(nil, :root)
      end
        
      context "with all arguments" do
        should "create a MumWidget instance with options" do
          proxy = widget(:mum, :mummy, :eating, :color => 'grey', :type => :hungry)
          @root << proxy
          
          assert_kind_of MumWidget, @root[:mummy]
          assert_equal :mummy, @root[:mummy].name
          assert_equal({:color => "grey", :type => :hungry}, @root[:mummy].options)
        end
      end
    
      should "not set options with 2 arguments" do
        @root << widget(:mum, :mummy)
        @mum = @root[:mummy]
        
        assert_kind_of MumWidget, @mum
        assert_equal :mummy, @mum.widget_id
        assert_equal({}, @mum.options)
      end
    
      should "set defaults with prefix, only" do
        @root << widget(:mum)
        @mum = @root[:mum]
        
        assert_kind_of MumWidget, @mum
        assert_equal :mum, @mum.name
        assert_equal({}, @mum.options)
      end
      
      should "yield itself" do
        ficken = widget(:mum) do |mum|
          mum << widget(:mouse, :kid)
        end
        @root << ficken
        assert_equal 2, @root[:mum].size
        assert_kind_of MouseWidget, @root[:mum][:kid]
      end
    end
  end
end
