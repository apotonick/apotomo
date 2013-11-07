require 'test_helper'

class EventHandlerTest < MiniTest::Spec
  include Apotomo::TestCaseMethods::TestController

  describe "EventHandler" do
    before do
      @mum = mouse
        @mum << mouse_mock(:kid)
    end

    it "respond to #process_event" do
      h = Apotomo::EventHandler.new
      e = Apotomo::Event.new(:squeak, @mum)
      assert_equal nil, h.process_event(e)
    end

    describe "#call" do
      it "push #process_events' results ordered to root's #page_updates" do
        [@mum, @mum[:kid], @mum].each_with_index do |source, i|
          e = Apotomo::Event.new(:squeak, source)
          h = Apotomo::EventHandler.new
          h.stub :process_event, "tick#{i}" do
            h.call(e)
          end
        end

        assert_equal 3, @mum.page_updates.size
        assert_equal "tick0", @mum.page_updates[0]
        assert_equal "tick1", @mum.page_updates[1]
        assert_equal "tick2", @mum.page_updates[2]
        assert_equal 0, @mum[:kid].page_updates.size
      end

      #TODO: handler expect #process_event
    end
  end

end
