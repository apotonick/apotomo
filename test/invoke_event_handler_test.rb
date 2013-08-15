require 'test_helper'

class EventHandlerTest < MiniTest::Spec
  include Apotomo::TestCaseMethods::TestController

  describe "Apotomo::InvokeEventHandler" do
    describe "constructor" do
      describe "without arguments" do
        it "set parameters to nil" do
          handler = Apotomo::InvokeEventHandler.new
          assert_nil handler.widget_id
          assert_nil handler.state
        end
      end

      describe "with options" do
        it "set parameters to options values" do
          handler = Apotomo::InvokeEventHandler.new(:widget_id => :widget, :state => :state)
          assert_equal :widget, handler.widget_id
          assert_equal :state,  handler.state
        end
      end
    end

    # TODO: test #process_event

    describe "equality methods" do
      it "handlers with the same parameters are equal" do
        handler1 = Apotomo::InvokeEventHandler.new(:widget_id => :widget, :state => :state)
        handler2 = Apotomo::InvokeEventHandler.new(:widget_id => :widget, :state => :state)

        assert handler1 == handler2
        assert handler2 == handler1
      end

      it "handlers with not the same parameters are not equal" do
        handler1 = Apotomo::InvokeEventHandler.new(:widget_id => :widget, :state => :state)

        handler3 = Apotomo::InvokeEventHandler.new(:widget_id => :another_widget, :state => :state)
        assert handler1 != handler3
        assert handler3 != handler1

        handler4 = Apotomo::InvokeEventHandler.new(:widget_id => :widget, :state => :another_state)
        assert handler1 != handler4
        assert handler4 != handler1

        handler5 = Apotomo::InvokeEventHandler.new
        assert handler1 != handler5
        assert handler5 != handler1
      end

      # TODO: What about InvokeEventHandler == EventHandler ?
    end

    describe "#to_s" do
      it "return inspect of the handler" do
        handler = Apotomo::InvokeEventHandler.new
        handler.widget_id = :widget_id
        handler.state     = :my_state
        assert_equal "InvokeEventHandler:widget_id#my_state", handler.to_s
      end
    end
  end

end
