require 'test_helper'

class EventHandlerTest < MiniTest::Spec
  include Apotomo::TestCaseMethods::TestController

  describe "InvokeEventHandler" do
    describe "constructor" do
      it "accept no arguments and create clean instance" do
        h = Apotomo::InvokeEventHandler.new

        assert_nil h.widget_id
        assert_nil h.state
      end

      it "accept options and set them" do
        h = Apotomo::InvokeEventHandler.new(:widget_id => :widget, :state => :state)

        assert_equal :widget, h.widget_id
        assert_equal :state,  h.state
      end
    end

    describe "equality methods" do
      it "repond to #==" do
        h1 = Apotomo::InvokeEventHandler.new(:widget_id => :widget, :state => :state)
        h2 = Apotomo::InvokeEventHandler.new(:widget_id => :widget, :state => :state)

        assert h1 == h2
        assert h2 == h1
      end

      it "repond to #!=" do
        h1 = Apotomo::InvokeEventHandler.new(:widget_id => :widget, :state => :state)

        h3 = Apotomo::InvokeEventHandler.new(:widget_id => :another_widget, :state => :state)
        assert h1 != h3
        assert h3 != h1

        h4 = Apotomo::InvokeEventHandler.new(:widget_id => :widget, :state => :another_state)
        assert h1 != h4
        assert h4 != h1

        h5 = Apotomo::InvokeEventHandler.new
        assert h1 != h5
        assert h5 != h1

        # TODO: test InvokeEventHandler == EventHandler
      end
    end

    it "respond to #to_s" do
      h = Apotomo::InvokeEventHandler.new
      h.widget_id = :widget_id
      h.state     = :my_state

      assert_equal "InvokeEventHandler:widget_id#my_state", h.to_s
    end
  end

  ### TODO: test #process_event

end
