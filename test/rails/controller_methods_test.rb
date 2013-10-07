require 'test_helper'

class ControllerMethodsTest < MiniTest::Spec
  include Apotomo::TestCaseMethods::TestController

  describe "A Rails controller" do
    describe "#apotomo_root" do
      it "initially return a root widget" do
        assert_equal 1, @controller.apotomo_root.size
      end

      it "allow tree modifications" do
        @controller.apotomo_root << mouse_mock
        assert_equal 2, @controller.apotomo_root.size
      end
    end

    it "respond to #apotomo_request_processor and initially return the processor which has an empty root" do
      assert_kind_of Apotomo::RequestProcessor, @controller.apotomo_request_processor
      assert_equal 1, @controller.apotomo_request_processor.root.size
    end

    describe "#has_widgets" do
      before do
        @controller.class.has_widgets do |root|
          root << widget(:mouse, 'mum')
        end
      end

      it "add the widgets to apotomo_root" do
        assert_kind_of MouseWidget, @controller.apotomo_root['mum']
        assert_equal 'mum', @controller.apotomo_root['mum'].name
      end

      it "allow multiple calls to has_widgets" do
        @controller.class.has_widgets do |root|
          root << widget(:mouse, 'kid')
        end

        assert_kind_of MouseWidget, @controller.apotomo_root['mum']
        assert_equal 'mum', @controller.apotomo_root['mum'].name
        assert_kind_of MouseWidget, @controller.apotomo_root['kid']
        assert_equal 'kid', @controller.apotomo_root['kid'].name
      end

      it "inherit has_widgets blocks to sub-controllers" do
        @sub_controller = Class.new(@controller.class) do
          has_widgets do |root|
            root << widget(:mouse, 'berry')
          end
        end.new
        @sub_controller.params = {}

        assert_kind_of MouseWidget, @sub_controller.apotomo_root['mum']
        assert_equal 'mum', @sub_controller.apotomo_root['mum'].name
        assert_kind_of MouseWidget, @sub_controller.apotomo_root['berry']
        assert_equal 'berry', @sub_controller.apotomo_root['berry'].name
      end

      it "be executed in controller describe" do
        @controller.instance_eval do
          def roomies
            ['mice', 'cows']
          end
        end

        @controller.class.has_widgets do |root|
          root << widget(:mouse, 'kid', :display, :roomies => roomies)
        end

        assert_equal ['mice', 'cows'], @controller.apotomo_root['kid'].options[:roomies]
      end
    end

    it "respond to #url_for_event and compute an url for any widget" do
      assert_equal "/barn/render_event_response?source=mouse&type=footsteps&volume=9", @controller.url_for_event(:footsteps, :source => :mouse, :volume => 9)
    end
  end

  it "respond to #render_widget and render the widget" do
    @mum = mouse_mock('mum', 'eating')
    @controller.apotomo_root << @mum

    assert_equal "<div id=\"mum\">burp!</div>\n", @controller.render_widget('mum', :eat)
  end
end
