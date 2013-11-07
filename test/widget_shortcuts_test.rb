require 'test_helper'

class MumWidget < MouseWidget
end

class MouseTabsWidget < Apotomo::Widget
end

class WidgetShortcutsTest < MiniTest::Spec
  describe "FactoryProxy" do
    before do
      @factory = Apotomo::WidgetShortcuts::FactoryProxy
    end

    # DISCISS: needed?
    describe "#constant_for" do
      before do
        @dsl = @factory.new(:class, :id)
      end

      it "constantize symbols" do
        assert_equal MouseWidget, @dsl.send(:constant_for, :mouse)
      end

      # DISCISS: needed?
      it "not try to singularize the widget class" do
        assert_equal MouseTabsWidget, @dsl.send(:constant_for, :mouse_tabs)
      end
    end

    describe "#widget and #<<" do
      before do
        @root = Apotomo::Widget.new(nil, :root)
      end

      it "create a widget instance with options and set them" do
        proxy = widget(:mum, :mummy, :eating, :color => 'grey', :type => :hungry)
        @root << proxy

        assert_kind_of MumWidget, @root[:mummy]
        assert_equal :mummy, @root[:mummy].name
        assert_equal({:color => "grey", :type => :hungry}, @root[:mummy].options)
      end

      it "create a widget instance without options" do
        @root << widget(:mum, :mummy)
        @mum = @root[:mummy]

        assert_kind_of MumWidget, @mum
        assert_equal :mummy, @mum.widget_id
        assert_equal({}, @mum.options)
      end

      it "create a widget instance with prefix argument only (id is equal to prefix)" do
        @root << widget(:mum)
        @mum = @root[:mum]

        assert_kind_of MumWidget, @mum
        assert_equal :mum, @mum.name
        assert_equal({}, @mum.options)
      end

      it "create a widget instance and yield itself" do
        # TODO: don't create a subwidget but use expectations
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
