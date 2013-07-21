require 'test_helper'

class MumWidget < MouseWidget; end
class MouseTabsWidget;end

class WidgetShortcutsTest < MiniTest::Spec
  describe "FactoryProxy" do
    before do
      @factory = Apotomo::WidgetShortcuts::FactoryProxy
    end

    describe "#constant_for" do
      before do
        @dsl = @factory.new(:class, :id)
      end

      it "constantize symbols" do
        assert_equal MouseWidget, @dsl.send(:constant_for, :mouse)
      end

      it "not try to singularize the widget class" do
        assert_equal MouseTabsWidget, @dsl.send(:constant_for, :mouse_tabs)
      end
    end

    describe "#widget and #<<" do
      before do
        @root = Apotomo::Widget.new(nil, :root)
      end

      describe "with all arguments" do
        it "create a MumWidget instance with options" do
          proxy = widget(:mum, :mummy, :eating, :color => 'grey', :type => :hungry)
          @root << proxy

          assert_kind_of MumWidget, @root[:mummy]
          assert_equal :mummy, @root[:mummy].name
          assert_equal({:color => "grey", :type => :hungry}, @root[:mummy].options)
        end
      end

      it "not set options with 2 arguments" do
        @root << widget(:mum, :mummy)
        @mum = @root[:mummy]

        assert_kind_of MumWidget, @mum
        assert_equal :mummy, @mum.widget_id
        assert_equal({}, @mum.options)
      end

      it "set defaults with prefix, only" do
        @root << widget(:mum)
        @mum = @root[:mum]

        assert_kind_of MumWidget, @mum
        assert_equal :mum, @mum.name
        assert_equal({}, @mum.options)
      end

      it "yield itself" do
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
